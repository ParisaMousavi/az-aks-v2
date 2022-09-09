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

variable "vnet_subnet_id" {
  type = string
}

variable "additional_tags" {
  default = {}
  type    = map(string)
}
