output "principal_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}