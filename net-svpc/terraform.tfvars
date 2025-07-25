billing_account_id = "123456-7890AB-CDEF12" # Replace with your actual billing account ID
folder_id          = "832895978042"
region             = "europe-central2"

labels = {
  environment = "production"
  team        = "fintech-technology-devops"
  cost_center = "fintech-technology-devops"
  owner       = "fintech-technology-devops"
}

enable_private_google_access = true
enable_flow_logs             = true

flow_logs_config = {
  aggregation_interval = "INTERVAL_10_MIN"
  flow_sampling        = 0.5
  metadata             = "INCLUDE_ALL_METADATA"
}

nat_config = {
  min_ports_per_vm                    = 64
  max_ports_per_vm                    = 65536
  enable_endpoint_independent_mapping = true
  tcp_established_idle_timeout_sec    = 1200
  tcp_transitory_idle_timeout_sec     = 30
  udp_idle_timeout_sec                = 30
}

firewall_config = {
  enable_ssh_from_iap       = true
  enable_health_checks      = true
  enable_internal_traffic   = true
  allowed_ssh_source_ranges = ["35.235.240.0/20"]
}

project_id    = "fintech-prod-host-project"
gke_vpc_name  = "gke-vpc"
data_vpc_name = "data-vpc"

gke_subnet = {
  name          = "gke-subnet"
  ip_cidr_range = "10.60.4.0/22"
  secondary_ip_ranges = [
    {
      range_name    = "pods"
      ip_cidr_range = "10.60.128.0/17"
    },
    {
      range_name    = "services"
      ip_cidr_range = "10.60.8.0/22"
    }
  ]
  private_ip_google_access = true
  log_config = {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

gke_proxy_subnet = {
  name          = "gke-proxy-subnet"
  ip_cidr_range = "10.60.0.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

gke_control_plane_subnet = {
  name                     = "gke-control-plane-subnet"
  ip_cidr_range            = "10.60.1.0/28"
  private_ip_google_access = true
  log_config = {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

data_subnet = {
  name          = "data-subnet"
  ip_cidr_range = "10.61.4.0/22"
  secondary_ip_ranges = [
    {
      range_name    = "composer-pods"
      ip_cidr_range = "10.61.128.0/17"
    },
    {
      range_name    = "composer-services"
      ip_cidr_range = "10.61.8.0/22"
    }
  ]
  private_ip_google_access = true
  log_config = {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

data_proxy_subnet = {
  name          = "data-proxy-subnet"
  ip_cidr_range = "10.61.0.0/24"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

gke_cloud_nat_config = {
  router_name                        = "fintech-prod-gke-router"
  router_region                      = "europe-central2"
  router_asn                         = 64514
  nat_name                           = "fintech-prod-gke-nat"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

data_cloud_nat_config = {
  router_name                        = "fintech-prod-data-router"
  router_region                      = "europe-central2"
  router_asn                         = 64514
  nat_name                           = "fintech-prod-data-nat"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config = {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

gke_firewall_rules = {
  gke-allow-internal = {
    name                    = "gke-allow-internal"
    description             = "Allow internal traffic within GKE VPC"
    direction               = "INGRESS"
    priority                = 1000
    disabled                = false
    enable_logging          = false
    source_ranges           = ["10.60.0.0/16", "10.61.0.0/16"]
    destination_ranges      = null
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["gke-node", "fintech-prod-gke-cluster-node"]
    target_service_accounts = null
    allow = [
      {
        protocol = "tcp"
        ports    = ["0-65535"]
      },
      {
        protocol = "udp"
        ports    = ["0-65535"]
      },
      {
        protocol = "icmp"
        ports    = []
      }
    ]
    deny = []
  }

  gke-allow-pods = {
    name                    = "gke-allow-pods"
    description             = "Allow GKE pods to communicate with each other"
    direction               = "INGRESS"
    priority                = 1000
    disabled                = false
    enable_logging          = false
    source_ranges           = ["10.60.128.0/17"]  # GKE pods subnet
    destination_ranges      = null
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["gke-node", "fintech-prod-gke-cluster-node"]
    target_service_accounts = null
    allow = [
      {
        protocol = "tcp"
        ports    = ["0-65535"]
      },
      {
        protocol = "udp"
        ports    = ["0-65535"]
      },
      {
        protocol = "icmp"
        ports    = []
      }
    ]
    deny = []
  }
  
  gke-allow-atlassian-cicd = {
    name                    = "gke-allow-atlassian-cicd"
    description             = "Allow Atlassian IP ranges for CI/CD access to GKE cluster"
    direction               = "INGRESS"
    priority                = 1000
    disabled                = false
    enable_logging          = false
    source_ranges = []
    destination_ranges      = null
    source_tags             = null
    source_service_accounts = null
    target_tags             = ["gke-node", "fintech-prod-gke-cluster-node"]
    target_service_accounts = null
    allow = [
      {
        protocol = "tcp"
        ports    = ["443", "6443", "8080", "8443"]
      }
    ]
    deny = []
  }
}

data_firewall_rules = {
  data-allow-internal = {
    name                    = "data-allow-internal"
    description             = "Allow internal traffic within Data VPC"
    direction               = "INGRESS"
    priority                = 1000
    disabled                = false
    enable_logging          = false
    source_ranges           = ["10.60.0.0/16", "10.61.0.0/16"]
    destination_ranges      = null
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [
      {
        protocol = "tcp"
        ports    = ["0-65535"]
      },
      {
        protocol = "udp"
        ports    = ["0-65535"]
      },
      {
        protocol = "icmp"
        ports    = []
      }
    ]
    deny = []
  }
}

gke_vpc_peering_config = {
  gke_to_data = {
    name                 = "gke-to-data-peering"
    peer_network         = "projects/fintech-prod-host-project/global/networks/data-vpc"
    auto_create_routes   = true
    export_custom_routes = true
    import_custom_routes = true
  }
}

data_vpc_peering_config = {
  data_to_gke = {
    name                 = "data-to-gke-peering"
    peer_network         = "projects/fintech-prod-host-project/global/networks/gke-vpc"
    auto_create_routes   = true
    export_custom_routes = true
    import_custom_routes = true
  }
}

enable_shared_vpc = true

gke_subnet_iam_bindings = {
  gke-subnet = {
    subnetwork = "gke-subnet"
    region     = "europe-central2"
    members = [
      # GKE service accounts will be added dynamically based on service projects
    ]
  }
  gke-proxy-subnet = {
    subnetwork = "gke-proxy-subnet"
    region     = "europe-central2"
    members = [
      # GKE service accounts will be added dynamically based on service projects
    ]
  }
  # Note: gke-control-plane-subnet is excluded as per requirements
}

data_subnet_iam_bindings = {
  data-subnet = {
    subnetwork = "data-subnet"
    region     = "europe-central2"
    members = [
      # Data service accounts will be added dynamically based on service projects
    ]
  }
  data-proxy-subnet = {
    subnetwork = "data-proxy-subnet"
    region     = "europe-central2"
    members = [
      # Data service accounts will be added dynamically based on service projects
    ]
  }
}

data_private_service_access_ranges = {
  cloudsql = {
    name          = "fintech-prod-private-sql"
    ip_cidr_range = "10.61.1.0/24"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
  },
  cloudsql_replica = {
    name          = "fintech-prod-sql-replica"
    ip_cidr_range = "10.61.2.0/24"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
  },
  redis = {
    name          = "fintech-prod-private-redis"
    ip_cidr_range = "10.61.12.0/28"
    purpose       = "VPC_PEERING"
    address_type  = "INTERNAL"
  }
}

dns_config = {
  private-zone = {
    name        = "fintech-prod-internal"
    dns_name    = "fintech-prod.internal."
    description = "Private DNS zone for fintech production environment"
    networks = [
      "projects/fintech-prod-host-project/global/networks/gke-vpc",
      "projects/fintech-prod-host-project/global/networks/data-vpc"
    ]
  }
}

#dns_records = {
#  gke = {
#    name     = "gke.fintech-prod.internal."
#    zone_key = "private-zone"
#    type     = "A"
#    ttl      = 300
#    rrdatas  = ["10.60.4.10"]
#  }
#  api = {
#    name     = "api.fintech-prod.internal."
#    zone_key = "private-zone"
#    type     = "A"
#    ttl      = 300
#    rrdatas  = ["10.60.4.11"]
#  }
#  sql = {
#    name     = "sql.fintech-prod.internal."
#    zone_key = "private-zone"
#    type     = "A"
#    ttl      = 300
#    rrdatas  = ["10.61.4.10"]
#  }
#  composer = {
#    name     = "composer.fintech-prod.internal."
#    zone_key = "private-zone"
#    type     = "A"
#    ttl      = 300
#    rrdatas  = ["10.61.4.11"]
#  }
#}


