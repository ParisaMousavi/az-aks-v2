resource "azurerm_kubernetes_cluster" "this" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  node_resource_group              = var.node_resource_group
  private_cluster_enabled          = var.private_cluster_enabled
  sku_tier                         = var.sku_tier
  oidc_issuer_enabled              = var.oidc_issuer_enabled
  http_application_routing_enabled = var.http_application_routing_enabled
  dynamic "oms_agent" {
    for_each = var.logging.log_analytics_workspace_id != null && var.logging.enable_oms_agent == true ? [1] : []
    content {
      log_analytics_workspace_id = var.logging.log_analytics_workspace_id
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
    # scale_down_mode     = var.default_node_pool.scale_down_mode
  }
  # Reference: https://learn.microsoft.com/en-us/azure/aks/use-managed-identity#bring-your-own-control-plane-managed-identity
  # A service principal or managed identity is needed 
  # to dynamically create and manage other Azure resources such 
  # as an Azure load balancer or container registry (ACR)
  identity {
    type         = length(var.identity_ids) == 0 ? "SystemAssigned" : "UserAssigned"
    identity_ids = var.identity_ids
  }
  dynamic "kubelet_identity" {
    for_each = var.kubelet_identity.client_id != null && length(var.identity_ids) >= 1 ? [1] : []
    content {
      client_id                 = var.kubelet_identity.client_id
      object_id                 = var.kubelet_identity.object_id
      user_assigned_identity_id = var.kubelet_identity.user_assigned_identity_id
    }
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
    managed                = var.aad_config.managed
    admin_group_object_ids = var.aad_config.admin_group_object_ids
    azure_rbac_enabled     = var.aad_config.azure_rbac_enabled
    tenant_id              = var.aad_config.tenant_id
  }
  linux_profile {
    admin_username = var.linux_profile.admin_username
    ssh_key {
      key_data = replace(var.linux_profile.key_data, "\n", "")
    }
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
}

# resource "azurerm_role_assignment" "aks_user_role" {
#   for_each             = toset(var.aad_config.admin_group_object_ids)
#   scope                = azurerm_kubernetes_cluster.this.id
#   role_definition_name = "Azure Kubernetes Service Cluster User Role"
#   principal_id         = each.value
# }

# resource "azurerm_role_assignment" "aks_admin_role" {
#   for_each             = toset(var.aad_config.admin_group_object_ids)
#   scope                = azurerm_kubernetes_cluster.this.id
#   role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
#   principal_id         = each.value
# }


# https://docs.microsoft.com/de-de/azure/azure-monitor/essentials/resource-manager-diagnostic-settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.logging.log_analytics_workspace_id != null && var.logging.enabele_diagnostic_setting == true ? 1 : 0
  name                       = "logs2workspace"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.logging.log_analytics_workspace_id
  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "guard"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "cloud-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "csi-azuredisk-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "csi-azurefile-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  log {
    category = "csi-snapshot-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }
}
