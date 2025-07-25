variable "project_id" {
  description = "The ID of the project where the VPCs will be created"
  type        = string
}

variable "folder_id" {
  description = "The folder ID where the projects will be created"
  type        = string
}

variable "gke_vpc_name" {
  description = "The name of the GKE VPC network"
  type        = string
  default     = "gke-vpc"
}

variable "data_vpc_name" {
  description = "The name of the Data VPC network"
  type        = string
  default     = "data-vpc"
}

variable "region" {
  description = "The region where the VPC will be created"
  type        = string
}

variable "gke_subnet" {
  description = "Configuration for the GKE subnet"
  type = object({
    name          = string
    ip_cidr_range = string
    secondary_ip_ranges = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
    private_ip_google_access = bool
    log_config = object({
      aggregation_interval = string
      flow_sampling        = number
      metadata             = string
    })
  })
}

variable "gke_proxy_subnet" {
  description = "Configuration for the GKE VPC proxy subnet"
  type = object({
    name          = string
    ip_cidr_range = string
    purpose       = optional(string)
    role          = optional(string)
  })
}

variable "gke_control_plane_subnet" {
  description = "Configuration for the GKE control plane subnet"
  type = object({
    name                     = string
    ip_cidr_range            = string
    private_ip_google_access = bool
    log_config = object({
      aggregation_interval = string
      flow_sampling        = number
      metadata             = string
    })
  })
}

variable "data_subnet" {
  description = "Configuration for the data subnet"
  type = object({
    name          = string
    ip_cidr_range = string
    secondary_ip_ranges = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
    private_ip_google_access = bool
    log_config = object({
      aggregation_interval = string
      flow_sampling        = number
      metadata             = string
    })
  })
}

variable "data_proxy_subnet" {
  description = "Configuration for the Data VPC proxy subnet"
  type = object({
    name          = string
    ip_cidr_range = string
    purpose       = optional(string)
    role          = optional(string)
  })
}

variable "gke_cloud_nat_config" {
  description = "Configuration for GKE Cloud NAT"
  type = object({
    router_name                        = string
    router_region                      = string
    router_asn                         = number
    nat_name                           = string
    nat_ip_allocate_option             = string
    source_subnetwork_ip_ranges_to_nat = string
    log_config = object({
      enable = bool
      filter = string
    })
  })
}

variable "data_cloud_nat_config" {
  description = "Configuration for Data Cloud NAT"
  type = object({
    router_name                        = string
    router_region                      = string
    router_asn                         = number
    nat_name                           = string
    nat_ip_allocate_option             = string
    source_subnetwork_ip_ranges_to_nat = string
    log_config = object({
      enable = bool
      filter = string
    })
  })
}

variable "gke_firewall_rules" {
  description = "Map of GKE firewall rules to create"
  type = map(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    disabled                = bool
    enable_logging          = bool
    source_ranges           = list(string)
    destination_ranges      = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}

variable "data_firewall_rules" {
  description = "Map of Data firewall rules to create"
  type = map(object({
    name                    = string
    description             = string
    direction               = string
    priority                = number
    disabled                = bool
    enable_logging          = bool
    source_ranges           = list(string)
    destination_ranges      = list(string)
    source_tags             = list(string)
    source_service_accounts = list(string)
    target_tags             = list(string)
    target_service_accounts = list(string)
    allow = list(object({
      protocol = string
      ports    = list(string)
    }))
    deny = list(object({
      protocol = string
      ports    = list(string)
    }))
  }))
}

variable "vpc_peering_config" {
  description = "Map of VPC peering configurations"
  type = map(object({
    name                 = string
    peer_network         = string
    auto_create_routes   = optional(bool, true)
    export_custom_routes = optional(bool, false)
    import_custom_routes = optional(bool, false)
  }))
  default = {}
}

variable "gke_vpc_peering_config" {
  description = "Map of GKE VPC peering configurations"
  type = map(object({
    name                 = string
    peer_network         = string
    auto_create_routes   = optional(bool, true)
    export_custom_routes = optional(bool, false)
    import_custom_routes = optional(bool, false)
  }))
  default = {}
}

variable "data_vpc_peering_config" {
  description = "Map of Data VPC peering configurations"
  type = map(object({
    name                 = string
    peer_network         = string
    auto_create_routes   = optional(bool, true)
    export_custom_routes = optional(bool, false)
    import_custom_routes = optional(bool, false)
  }))
  default = {}
}

variable "enable_shared_vpc" {
  description = "Whether to enable Shared VPC"
  type        = bool
  default     = false
}

variable "gke_service_projects" {
  description = "Map of GKE service projects to attach to the GKE Shared VPC"
  type        = map(string)
  default     = {}
}

variable "data_service_projects" {
  description = "Map of data service projects to attach to the Data Shared VPC"
  type        = map(string)
  default     = {}
}

variable "gke_subnet_iam_bindings" {
  description = "IAM bindings for GKE subnet-level access control"
  type = map(object({
    subnetwork = string
    region     = string
    members    = list(string)
  }))
  default = {}
}

variable "data_subnet_iam_bindings" {
  description = "IAM bindings for Data subnet-level access control"
  type = map(object({
    subnetwork = string
    region     = string
    members    = list(string)
  }))
  default = {}
}

variable "dns_config" {
  description = "Map of DNS zone configurations"
  type = map(object({
    name        = string
    dns_name    = string
    description = string
    networks    = list(string)
  }))
}

#variable "dns_records" {
#  description = "Map of DNS records to create"
#  type = map(object({
#    name     = string
#    zone_key = string
#    type     = string
#    ttl      = number
#    rrdatas  = list(string)
#  }))
#}

variable "labels" {
  description = "Map of labels to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "billing_account" {
  description = "The billing account ID to associate with the projects."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID to associate with the projects"
  type        = string
}

variable "enable_private_google_access" {
  description = "Whether to enable private Google access for subnets."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Whether to enable flow logs for subnets."
  type        = bool
  default     = true
}

variable "flow_logs_config" {
  description = "Configuration for flow logs."
  type = object({
    aggregation_interval = string
    flow_sampling        = number
    metadata             = string
  })
  default = {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

variable "nat_config" {
  description = "Configuration for Cloud NAT."
  type = object({
    min_ports_per_vm                    = number
    max_ports_per_vm                    = number
    enable_endpoint_independent_mapping = bool
    tcp_established_idle_timeout_sec    = number
    tcp_transitory_idle_timeout_sec     = number
    udp_idle_timeout_sec                = number
  })
  default = {
    min_ports_per_vm                    = 64
    max_ports_per_vm                    = 65536
    enable_endpoint_independent_mapping = true
    tcp_established_idle_timeout_sec    = 1200
    tcp_transitory_idle_timeout_sec     = 30
    udp_idle_timeout_sec                = 30
  }
}

variable "firewall_config" {
  description = "Configuration for firewall rules."
  type = object({
    enable_ssh_from_iap       = bool
    enable_health_checks      = bool
    enable_internal_traffic   = bool
    allowed_ssh_source_ranges = list(string)
  })
  default = {
    enable_ssh_from_iap       = true
    enable_health_checks      = true
    enable_internal_traffic   = true
    allowed_ssh_source_ranges = ["35.235.240.0/20"]
  }
}

variable "iap_config" {
  description = "Configuration for Identity-Aware Proxy (IAP)."
  type = object({
    enabled = bool
  })
  default = {
    enabled = false
  }
}

variable "data_private_service_access_ranges" {
  description = "Map of private service access IP ranges for data VPC"
  type = map(object({
    name          = string
    ip_cidr_range = string
    purpose       = optional(string, "VPC_PEERING")
    address_type  = optional(string, "INTERNAL")
  }))
  default = {}
}