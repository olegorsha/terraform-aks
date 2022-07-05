output "vnet_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "apgw_subnet_id" {
  value = azurerm_subnet.app_gwsubnet.id
}

output "public_subnet_id" {
  value = azurerm_subnet.public_subnet.id
}
