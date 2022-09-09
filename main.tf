resource "azurerm_kubernetes_cluster" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix
  kubernetes_version      = var.kubernetes_version
  node_resource_group     = var.node_resource_group
  private_cluster_enabled = var.private_cluster_enabled
  sku_tier                = "Free"
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
    vnet_subnet_id  = var.vnet_subnet_id
  }
  identity {
    type = "SystemAssigned"
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}
