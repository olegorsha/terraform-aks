resource "azurerm_virtual_network" "virtual_network" {
  name                = "${var.name}-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = [var.network_address_space]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = var.aks_subnet_address_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "app_gwsubnet" {
  name                 = var.appgw_subnet_address_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.appgw_subnet_address_prefix]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = var.public_subnet_address_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.public_subnet_address_prefix]
}
