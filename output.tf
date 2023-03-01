output "principal_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "id" {
  value = azurerm_kubernetes_cluster.this.id
}


output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "http_application_routing_zone_name" {
  value = azurerm_kubernetes_cluster.this.http_application_routing_zone_name
}

output "oidc_issuer_url" {
  value = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "key_vault_secrets_provider" {
  value = azurerm_kubernetes_cluster.this.key_vault_secrets_provider
}

output "oms_agent_identity" {
  value = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity
  # var.logging.log_analytics_workspace_id != null && var.logging.enable_oms_agent == true ? {
  #   client_id                 = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity.client_id
  #   object_id                 = azurerm_kubernetes_cluster.this.oms_agent[0].oms_agent_identity.object_id
  #   user_assigned_identity_id = azurerm_kubernetes_cluster.this.oms_agent[o].oms_agent_identity.user_assigned_identity_id
  #   } : {
  #   client_id                 = null
  #   object_id                 = null
  #   user_assigned_identity_id = null
  # }
}