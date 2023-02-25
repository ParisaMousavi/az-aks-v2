resource "azurerm_kubernetes_cluster" "this" {
  name                             = var.name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  dns_prefix                       = var.dns_prefix
  kubernetes_version               = var.kubernetes_version
  node_resource_group              = var.node_resource_group
  private_cluster_enabled          = var.private_cluster_enabled
  sku_tier                         = var.sku_tier
  oidc_issuer_enabled              = var.oidc_issuer_enabled # https://learn.microsoft.com/en-us/azure/aks/cluster-configuration
  workload_identity_enabled        = var.workload_identity_enabled
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
    zones               = var.default_node_pool.zones
    vm_size             = var.default_node_pool.vm_size
    # scale_down_mode     = var.default_node_pool.scale_down_mode
    node_labels = merge(
      var.node_labels,
      {
        created-by = "iac-tf",
        type       = "system-pool"
      },
    ) # Reference page : https://learn.microsoft.com/en-us/azure/aks/use-labels
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
  azure_active_directory_role_based_access_control {
    managed                = var.aad_config.managed
    admin_group_object_ids = var.aad_config.admin_group_object_ids
    azure_rbac_enabled     = var.aad_config.azure_rbac_enabled
    tenant_id              = var.aad_config.tenant_id
  } # Example : https://aravinda-kumar.com/docs/Azure/aks-security-part-1/index.html
  linux_profile {
    admin_username = var.linux_profile.admin_username
    ssh_key {
      key_data = replace(var.linux_profile.key_data, "\n", "")
    }
  }
  storage_profile {
    blob_driver_enabled         = var.storage_profile.blob_driver_enabled
    disk_driver_enabled         = var.storage_profile.disk_driver_enabled
    disk_driver_version         = var.storage_profile.disk_driver_version
    file_driver_enabled         = var.storage_profile.file_driver_enabled
    snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
  }
  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider.secret_rotation_enabled == false ? [] : [1]
    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider.secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider.secret_rotation_interval
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
  enabled_log {
    category = "kube-apiserver"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "kube-audit"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "kube-audit-admin"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "kube-controller-manager"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "kube-scheduler"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "cluster-autoscaler"
    retention_policy {
      enabled = true
    }
  }

  enabled_log {
    category = "guard"
    retention_policy {
      enabled = true
    }
  }
  enabled_log {
    category = "cloud-controller-manager"
    retention_policy {
      enabled = true
    }
  }
  enabled_log {
    category = "csi-azuredisk-controller"
    retention_policy {
      enabled = true
    }
  }
  enabled_log {
    category = "csi-azurefile-controller"
    retention_policy {
      enabled = true
    }
  }
  enabled_log {
    category = "csi-snapshot-controller"
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
