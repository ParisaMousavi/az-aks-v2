variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "node_resource_group" {
  type    = string
  default = null
}

variable "private_cluster_enabled" {
  type = bool
}

variable "additional_tags" {
  default = {}
  type    = map(string)
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
