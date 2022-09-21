resource "azurerm_kubernetes_cluster" "this" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  node_resource_group              = var.node_resource_group
  private_cluster_enabled          = var.private_cluster_enabled
  sku_tier                         = var.sku_tier
  http_application_routing_enabled = true
  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []
    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }
  default_node_pool {
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    max_count           = var.default_node_pool.max_count
    min_count           = var.default_node_pool.min_count
    max_pods            = var.default_node_pool.max_pods
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    os_sku              = var.default_node_pool.os_sku
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.default_node_pool.vnet_subnet_id
    vm_size             = var.default_node_pool.vm_size
  }
  identity {
    type         = "UserAssigned"
    identity_ids = var.identity_ids
  }
  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = var.network_profile.network_policy
    docker_bridge_cidr = var.network_profile.docker_bridge_cidr
    service_cidr       = var.network_profile.service_cidr
    dns_service_ip     = var.network_profile.dns_service_ip
    load_balancer_sku  = var.network_profile.load_balancer_sku
    outbound_type      = var.network_profile.outbound_type
  }

  # Example : https://aravinda-kumar.com/docs/Azure/aks-security-part-1/index.html
  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

resource "azurerm_role_assignment" "admin" {
  for_each = toset(var.admin_group_object_ids)
  scope = azurerm_kubernetes_cluster.this.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id = each.value
}