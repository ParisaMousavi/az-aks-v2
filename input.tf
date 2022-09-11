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


variable "log_analytics_workspace_id" {
  type = string
  default = null
}