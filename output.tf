output "principal_id" {
  value = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "id" {
  value = azurerm_kubernetes_cluster.this.id 
}


output "name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "all" {
  value = azurerm_kubernetes_cluster.this
}