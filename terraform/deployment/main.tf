# Cluster Resource Group

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.name}-rg"
  location = var.location
}

# AKS Cluster Network

module "aks_network" {
  source                         = "../modules/aks_network"
  name                           = var.name
  location                       = var.location
  resource_group_name            = azurerm_resource_group.resource_group.name
  network_address_space          = var.network_address_space
  aks_subnet_address_name        = var.aks_subnet_address_name
  aks_subnet_address_prefix      = var.aks_subnet_address_prefix
  appgw_subnet_address_name      = var.appgw_subnet_address_name
  appgw_subnet_address_prefix    = var.appgw_subnet_address_prefix
  public_subnet_address_name     = var.public_subnet_address_name
  public_subnet_address_prefix   = var.public_subnet_address_prefix
  services_subnet_address_name   = var.services_subnet_address_name
  services_subnet_address_prefix = var.services_subnet_address_prefix
  # subnet_cidr         = var.subnet_cidr
}

# # AKS Log Analytics

module "log_analytics" {
  source              = "../modules/log_analytics"
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
}


# # AKS Cluster

module "aks_cluster" {
  source                     = "../modules/aks-cluster"
  name                       = var.name
  # cluster_name             = var.cluster_name
  location                   = var.location
  # dns_prefix               = var.dns_prefix
  resource_group_name        = azurerm_resource_group.resource_group.name
  kubernetes_version         = var.kubernetes_version
  node_count                 = var.node_count
  #  addons                     = var.addons
  aks_admins_group_object_id = var.aks_admins_group_object_id
  ssh_public_key             = var.ssh_public_key
  system_pool_vm_size        = var.system_pool_vm_size
  user_pool_vm_size          = var.user_pool_vm_size
  # min_count                = var.min_count
  # max_count                = var.max_count
  # os_disk_size_gb          = "30"
  # max_pods                 = "30"
  #  vm_size        = var.vm_size
  aks_subnet_id              = module.aks_network.aks_subnet_id
  apgw_subnet_id             = module.aks_network.apgw_subnet_id
  # client_id                = module.aks_identities.cluster_client_id
  # client_secret            = module.aks_identities.cluster_sp_secret
  diagnostics_workspace_id   = module.log_analytics.azurerm_log_analytics_workspace
  depends_on                 = [
    module.aks_network,
    module.log_analytics
  ]
}

#module "auth" {
#  source = "../modules/auth"
#  name   = var.name
#  location = var.location
#  resource_group_name        = azurerm_resource_group.resource_group.name
#}

module "jumpbox" {
  source              = "../modules/jumpbox"
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.resource_group.name
  vnet_id             = module.aks_network.vnet_id
  subnet_id           = module.aks_network.public_subnet_id
  # dns_zone_name           = join(".", slice(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn), 1, length(split(".", azurerm_kubernetes_cluster.privateaks.private_fqdn))))
  # dns_zone_resource_group = azurerm_kubernetes_cluster.privateaks.node_resource_group
}

# module "bastion" {
#   source              = "../modules/bastion"
#   name                = var.name
#   location            = var.location
#   resource_group_name = azurerm_resource_group.resource_group.name

#   # Azure bastion server requireemnts
#   bastion_service_name          = "bastion-service"
#   bastion_subnet_address_prefix = [var.bastion_subnet_address_prefix]
#   bastion_host_sku              = "Standard"
#   scale_units                   = 2
# }



