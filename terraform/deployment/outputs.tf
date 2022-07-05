output "jumpbox_ip" {
  description = "Jumpbox VM IP"
  value       = module.jumpbox.jumpbox_ip
}

output "jumpbox_username" {
  description = "Jumpbox VM username"
  value       = module.jumpbox.jumpbox_username
}

output "jumpbox_password" {
  description = "Jumpbox VM admin password"
  value       = module.jumpbox.jumpbox_password
  sensitive = true
}

output "aks_cluster_identity_id" {
  value = module.aks_cluster.cluster_identity_id
}

output "kv_secrets_provider" {
  value = module.aks_cluster.kv_secrets_provider
}

# output "bastion_connection_command" {
#   description = "Bastion connection command"
#   value       = "az network bastion ssh --name ${module.bastion.bastion_service_name} --target-resource-id ${module.jumpbox.jumpbox_id} --auth-type password --username ${module.jumpbox.jumpbox_username} --resource-group ${var.name}-rg"
# }

output "data_azurerm_client_config_current" {
  value = module.aks_cluster.data_azurerm_client_config_current
}