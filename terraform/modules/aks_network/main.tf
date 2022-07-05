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

resource "azurerm_subnet" "services_subnet" {
  name                 = var.services_subnet_address_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.services_subnet_address_prefix]

  enforce_private_link_endpoint_network_policies = true

  #    List of Service endpoints to associate with the subnet.
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.ServiceBus",
    "Microsoft.ContainerRegistry",
    "Microsoft.Sql"
  ]

    delegation {
      name = "fs"
      service_delegation {
        name = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
      }
    }
}


resource "azurerm_network_security_group" "default" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#resource "azurerm_resource_group" "az_psql_rg" {
#  name     = "${var.name}-postgresql-rg"
#  location = "eastus" #var.location
#}

resource "azurerm_subnet_network_security_group_association" "default" {
  subnet_id                 = azurerm_subnet.services_subnet.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_private_dns_zone" "default" {
  name                = "${var.name}-pdz.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  depends_on = [azurerm_subnet_network_security_group_association.default]
}

resource "azurerm_private_dns_zone_virtual_network_link" "default" {
  name                  = "${var.name}-pdzvnetlink.com"
  private_dns_zone_name = azurerm_private_dns_zone.default.name
  virtual_network_id    = azurerm_virtual_network.virtual_network.id
  resource_group_name   = var.resource_group_name
}

resource "azurerm_postgresql_flexible_server" "default" {
  name                   = "${var.name}-server"
  resource_group_name    = var.resource_group_name
  location               = "eastus" #var.location
  version                = "13"
  delegated_subnet_id    = azurerm_subnet.services_subnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.default.id
  administrator_login    = "adminTerraform"
  administrator_password = "QAZwsx123"
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "GP_Standard_D2s_v3"
  backup_retention_days  = 7

  depends_on = [azurerm_private_dns_zone_virtual_network_link.default]
}

resource "azurerm_postgresql_flexible_server_database" "default" {
  name      = "${var.name}-db"
  server_id = azurerm_postgresql_flexible_server.default.id
  collation = "en_US.UTF8"
  charset   = "UTF8"
}

#resource "azurerm_resource_group" "az_psql_rg" {
#  name     = "${var.name}-postgresql-rg"
#  location = "eastus" #var.location
#}
#
#resource "azurerm_postgresql_server" "psql" {
#  name                = "${var.name}-psql-server"
#  location            = azurerm_resource_group.az_psql_rg.location
#  resource_group_name = azurerm_resource_group.az_psql_rg.name
#
#  administrator_login          = "psqladminun"
#  administrator_login_password = "H@Sh1CoR3!"
#
#  sku_name   = "GP_Gen5_2" #"GP_Gen5_4"
#  version    = "11"
#  storage_mb = 5120 #640000
#
#  backup_retention_days            = 7
#  geo_redundant_backup_enabled     = false #true
#  auto_grow_enabled                = false #true
#  public_network_access_enabled    = true
#  ssl_enforcement_enabled          = false
#  # ssl_minimal_tls_version_enforced = "TLS1_2"
#  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
#
#  tags = {
#    Environment = "dev"
#  }
#}
#
#resource "azurerm_private_endpoint" "psql" {
#  name                = "${var.name}-psql-private-endpoint"
#  location            = azurerm_resource_group.az_psql_rg.location
#  resource_group_name = azurerm_resource_group.az_psql_rg.name
#  subnet_id           = azurerm_subnet.services_subnet.id
#
#  private_service_connection {
#    name                           = "${var.name}-psql-privateserviceconnection"
#    private_connection_resource_id = azurerm_postgresql_server.psql.id
#    subresource_names              = ["postgresqlServer"]
#    is_manual_connection           = false
#  }
#}
#
#resource "azurerm_postgresql_virtual_network_rule" "example" {
#  name                                 = "postgresql-vnet-rule"
#  resource_group_name                  = azurerm_resource_group.az_psql_rg.name
#  server_name                          = azurerm_postgresql_server.psql.name
#  subnet_id                            = azurerm_subnet.services_subnet.id
#  ignore_missing_vnet_service_endpoint = true
#}
