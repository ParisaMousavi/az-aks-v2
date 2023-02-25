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