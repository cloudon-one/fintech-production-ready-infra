provider "google" {
  region = var.region
}

data "terraform_remote_state" "net_svpc" {
  backend = "gcs"
  config = {
    bucket = var.net_svpc_backend_bucket
    prefix = var.net_svpc_backend_prefix
  }
}

data "terraform_remote_state" "svc_projects" {
  backend = "gcs"
  config = {
    bucket = var.svc_projects_backend_bucket
    prefix = var.svc_projects_backend_prefix
  }
}

data "terraform_remote_state" "net_iam" {
  backend = "gcs"
  config = {
    bucket = var.net_iam_backend_bucket
    prefix = var.net_iam_backend_prefix
  }
}

locals {
  gke_project_id      = data.terraform_remote_state.svc_projects.outputs.gke_project_id
  host_project_id     = data.terraform_remote_state.net_svpc.outputs.host_project_id
  network_id          = data.terraform_remote_state.net_svpc.outputs.gke_network_id
  network_name        = data.terraform_remote_state.net_svpc.outputs.gke_network_name
  subnetwork_id       = data.terraform_remote_state.net_svpc.outputs.gke_subnet_id
  pods_range_name     = data.terraform_remote_state.net_svpc.outputs.gke_pods_secondary_range_name
  services_range_name = data.terraform_remote_state.net_svpc.outputs.gke_services_secondary_range_name
  gke_cluster_name    = var.gke_config.cluster_name_suffix != "" ? "fintech-prod-gke-${var.gke_config.cluster_name_suffix}" : "fintech-prod-gke"

  gke_zones = [
    "${var.region}-a",
    "${var.region}-b",
    "${var.region}-c"
  ]

  all_node_pools = var.gke_node_pools_config

  common_labels = merge(var.labels, {
    environment     = "production"
    project         = "fintech"
    managed_by      = "terraform"
    deployment_date = formatdate("YYYY-MM-DD", timestamp())
    component       = "gke"
  })
}

module "fintech_gke_cluster" {
  count  = var.gke_config.enabled ? 1 : 0
  source = "../modules/terraform-google-gke"

  project_id   = local.gke_project_id
  cluster_name = local.gke_cluster_name
  region       = var.region
  network      = local.network_id
  subnetwork   = local.subnetwork_id

  ip_allocation_policy = {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
    cluster_ipv4_cidr_block       = null
    services_ipv4_cidr_block      = null
  }

  master_ipv4_cidr_block            = var.gke_config.master_ipv4_cidr_block
  private_endpoint_subnetwork       = "projects/${local.host_project_id}/regions/${var.region}/subnetworks/gke-control-plane-subnet"
  enable_private_endpoint           = false
  master_authorized_networks        = var.gke_config.master_authorized_networks
  create_service_account            = var.gke_config.create_service_account
  enable_network_policy             = false
  enable_http_load_balancing        = var.gke_config.enable_http_load_balancing
  enable_horizontal_pod_autoscaling = var.gke_config.enable_horizontal_pod_autoscaling
  enable_vertical_pod_autoscaling   = var.gke_config.enable_vertical_pod_autoscaling
  datapath_provider                 = "ADVANCED_DATAPATH"
  enable_intranode_visibility       = false
  enable_fqdn_network_policy        = false
  enable_secret_manager             = true
  dns_config = {
    cluster_dns_domain = "cluster.local"
  }
  gateway_api_config = {
    channel = "CHANNEL_STANDARD"
  }

  resource_labels = {
    cost_center = "fintech"
    environment = "production"
    managed_by  = "terraform"
    owner       = "fintech-technology-devops"
    project     = local.gke_project_id
  }

  confidential_nodes = {
    enabled = true
  }

  default_snat_status = {
    disabled = false
  }

  service_external_ips_config = {
    enabled = false
  }

  vertical_pod_autoscaling = {
    enabled = true
  }

  cluster_autoscaling = {
    enabled                     = true
    autoscaling_profile         = "BALANCED"
    auto_provisioning_locations = local.gke_zones
    auto_provisioning_defaults = {
      disk_size       = 100
      disk_type       = "pd-balanced"
      image_type      = "COS_CONTAINERD"
      oauth_scopes    = ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/cloud-platform"]
      service_account = "gke-service-account@${local.gke_project_id}.iam.gserviceaccount.com"
      management = {
        auto_repair  = true
        auto_upgrade = true
        upgrade_settings = {
          max_surge       = 1
          max_unavailable = 0
          strategy        = "SURGE"
        }
      }
      shielded_instance_config = {
        enable_integrity_monitoring = true
        enable_secure_boot          = true
      }
    }
    resource_limits = [
      {
        resource_type = "cpu"
        minimum       = 8
        maximum       = 16
      },
      {
        resource_type = "memory"
        minimum       = 16
        maximum       = 128
      }
    ]
  }

  addons_config = {
    dns_cache_config = {
      enabled = true
    }
    gce_persistent_disk_csi_driver_config = {
      enabled = true
    }
    gcp_filestore_csi_driver_config = {
      enabled = true
    }
    gcs_fuse_csi_driver_config = {
      enabled = true
    }
    gke_backup_agent_config = {
      enabled = true
    }
    network_policy_config = {
      disabled = true
    }
    config_connector_config = {
      enabled = false
    }
    ray_operator_config = {
      enabled = true
      ray_cluster_logging_config = {
        enabled = true
      }
      ray_cluster_monitoring_config = {
        enabled = true
      }
    }
    stateful_ha_config = {
      enabled = false
    }
  }

  security = {
    mode = "BASIC"
  }

  release_channel = var.gke_config.release_channel
  monitoring = {
    enable_components         = ["SYSTEM_COMPONENTS", "STORAGE", "POD", "DEPLOYMENT", "STATEFULSET", "DAEMONSET", "HPA", "JOBSET", "CADVISOR", "KUBELET", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
    enable_managed_prometheus = true
  }

  logging = {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]
  }
  deletion_protection = var.gke_config.deletion_protection

  maintenance_window = {
    daily_window_start_time = null
    recurring_window = {
      start_time = "2025-06-19T23:00:00Z"
      end_time   = "2025-06-20T23:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SA,SU"
    }
  }

  security_posture_config = {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_ENTERPRISE"
  }

  cost_management_config = {
    enabled = true
  }

  notification_config = {
    pubsub = {
      enabled = false
      topic   = null
    }
  }

  node_pool_auto_config = {
    resource_manager_tags = {}
    network_tags = {
      tags = ["gke-node"]
    }
    node_kubelet_config = {
      insecure_kubelet_readonly_port_enabled = "FALSE"
    }
  }

  node_pool_defaults = {
    node_config_defaults = {
      insecure_kubelet_readonly_port_enabled = "FALSE"
      logging_variant                        = "DEFAULT"
    }
  }

  node_pools = {
    for name, config in local.all_node_pools : name => {
      name              = config.name
      node_count        = config.node_count
      machine_type      = config.machine_type
      disk_size_gb      = config.disk_size_gb
      disk_type         = config.disk_type
      version           = "1.32.2-gke.1297002"
      node_locations    = config.zones
      max_pods_per_node = 110
      service_account   = "gke-service-account@${local.gke_project_id}.iam.gserviceaccount.com"
      oauth_scopes      = ["https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/cloud-platform"]
      labels            = config.labels
      tags              = [config.name]
      metadata          = { "disable-legacy-endpoints" = "true" }
      resource_labels = {
        "goog-gke-node-pool-provisioning-model" = "on-demand"
        "pool"                                  = config.name == "app-pool" ? "app-pool" : "service"
      }
      boot_disk_kms_key = "projects/fintech-general/locations/europe-central2/keyRings/fintech-prod-gke-kms/cryptoKeys/fintech-prod-gke-kms"
      confidential_nodes = {
        enabled = config.security.enable_confidential_computing
      }
      shielded_instance_config = {
        enable_integrity_monitoring = true
        enable_secure_boot          = true
      }
      advanced_machine_features = {
        enable_nested_virtualization = false
        threads_per_core             = 0
      }
      kubelet_config = {
        cpu_cfs_quota                          = false
        insecure_kubelet_readonly_port_enabled = "FALSE"
        pod_pids_limit                         = 0
        cpu_manager_policy                     = "none"
      }
      enable_confidential_storage = false
      logging_variant             = "DEFAULT"
      local_ssd_count             = 0
      guest_accelerator           = []
      image_type                  = "COS_CONTAINERD"
      preemptible                 = false
      spot                        = false
      resource_manager_tags       = {}
      gcfs_config = {
        enabled = true
      }
      taints = config.taints
      autoscaling = {
        min_node_count       = config.autoscaling.min_node_count
        max_node_count       = config.autoscaling.max_node_count
        location_policy      = config.autoscaling.location_policy
        total_min_node_count = null
        total_max_node_count = null
      }
      management = {
        auto_repair  = config.management.auto_repair
        auto_upgrade = config.management.auto_upgrade
      }
      upgrade_settings = {
        max_surge       = 1
        max_unavailable = 0
        strategy        = "SURGE"
      }
      network_config = {
        create_pod_range     = false
        enable_private_nodes = true
        pod_ipv4_cidr_block  = "10.60.128.0/17"
        pod_range            = "pods"
      }
      queued_provisioning = {
        enabled = false
      }
    }
  }

  timeouts = {
    create = "45m"
    update = "45m"
    delete = "45m"
  }

  labels = merge(local.common_labels, {
    cluster_type   = "private"
    workload_type  = "general"
    security_level = "high"
  })

  authenticator_groups_config = {
    security_group = var.gke_security_group
  }

  database_encryption = {
    state    = "ENCRYPTED"
    key_name = "projects/fintech-general/locations/europe-central2/keyRings/fintech-prod-gke-kms/cryptoKeys/fintech-prod-gke-kms"
  }

  pod_security_standards = var.gke_config.security.pod_security_standards
}

resource "google_service_account" "workload_service_accounts" {
  for_each = var.gke_config.workload_identity_service_accounts

  project      = local.gke_project_id
  account_id   = each.key
  display_name = each.value.display_name
  description  = each.value.description
}

resource "google_service_account_iam_binding" "workload_identity_bindings" {
  for_each = var.gke_config.workload_identity_service_accounts

  service_account_id = google_service_account.workload_service_accounts[each.key].name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.gke_project_id}.svc.id.goog[${each.value.kubernetes_namespace}/${each.value.kubernetes_service_account}]"
  ]
}

resource "google_project_iam_member" "workload_service_account_roles" {
  for_each = {
    for pair in flatten([
      for sa_name, sa_config in var.gke_config.workload_identity_service_accounts : [
        for role in sa_config.gcp_roles : {
          sa_name = sa_name
          role    = role
        }
      ]
    ]) : "${pair.sa_name}-${pair.role}" => pair
  }

  project = local.gke_project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.workload_service_accounts[each.value.sa_name].email}"
}

resource "google_compute_firewall" "gke_master_webhook_access" {
  count = var.gke_config.enabled ? 1 : 0

  project     = local.host_project_id
  name        = "allow-gke-master-webhook-${local.gke_cluster_name}"
  network     = local.network_id
  description = "Allow GKE master to access webhook admission controllers"
  direction   = "INGRESS"
  priority    = 1000

  allow {
    protocol = "tcp"
    ports    = ["8443", "9443", "15017"]
  }

  source_ranges = [var.gke_config.master_ipv4_cidr_block]
  target_tags   = ["gke-node", "${local.gke_cluster_name}-node"]
}