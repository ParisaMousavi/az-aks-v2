variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "node_resource_group" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "private_cluster_enabled" {
  type = bool
}

variable "identity_ids" {
  type = list(string)
}

variable "additional_tags" {
  default = {}
  type    = map(string)
}

variable "sku_tier" {
  type    = string
  default = "Free"
}

variable "default_node_pool" {
  type = object({
    name                = string
    vnet_subnet_id      = string
    node_count          = number
    min_count           = number
    max_count           = number
    enable_auto_scaling = bool
    max_pods            = number
    os_sku              = string
    type                = string
    vm_size             = string
    scale_down_mode     = string
    zones               = optional(list(string))
  })
}

variable "network_profile" {
  type = object({
    network_plugin     = string
    network_policy     = string
    docker_bridge_cidr = string
    service_cidr       = string
    dns_service_ip     = string
    load_balancer_sku  = string
    outbound_type      = string
  })

}

variable "logging" {
  type = object({
    log_analytics_workspace_id = string
    enable_oms_agent           = bool
    enabele_diagnostic_setting = bool
  })
  default = {
    enabele_diagnostic_setting = false
    enable_oms_agent           = false
    log_analytics_workspace_id = null
  }
}

variable "aad_config" {
  type = object({
    managed                = bool
    admin_group_object_ids = list(string)
    azure_rbac_enabled     = bool
    tenant_id              = string
  })
}

variable "http_application_routing_enabled" {
  type        = bool
  default     = false
  description = "By set to true a system assigned managed identity will be created."
}

#------------------------------------------------
# more about oidc
# https://learn.microsoft.com/en-us/azure/aks/learn/tutorial-kubernetes-workload-identity
# https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#oidc-issuer
#------------------------------------------------
variable "oidc_issuer_enabled" {
  type    = bool
  default = false
}

variable "workload_identity_enabled" {
  type    = bool
  default = false
}

#------------------------------------------------
# Reference: https://learn.microsoft.com/en-us/azure/aks/use-managed-identity
#------------------------------------------------
variable "kubelet_identity" {
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
}

variable "linux_profile" {
  type = object({
    admin_username = string
    key_data       = string
  })
}

variable "storage_profile" {
  type = object({
    blob_driver_enabled         = bool
    disk_driver_enabled         = bool
    disk_driver_version         = string
    file_driver_enabled         = bool
    snapshot_controller_enabled = bool
  })
}

variable "node_labels" {
  default = {}
  type    = map(string)
}


variable "key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string)
  })
}