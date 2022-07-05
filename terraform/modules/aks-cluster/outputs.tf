output "cluster_egress_ip" {
  value = data.azurerm_public_ip.public_ip.ip_address
}

output "cluster_identity_id" {
  value = azurerm_user_assigned_identity.aks_identity.principal_id
}

output "kv_secrets_provider" {
  value = data.azurerm_user_assigned_identity.kv_secrets_provider.principal_id
}

output "data_azurerm_client_config_current" {
  value = data.azurerm_client_config.current
}