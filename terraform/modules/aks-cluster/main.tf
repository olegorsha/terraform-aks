data "azurerm_client_config" "current" {}

resource "azurerm_container_registry" "acr" {
  name                = "containerRegistryBB1"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = var.resource_group_name
  location            = var.location
  # tags                = var.tags

  name = "${var.name}Identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "acrpull_role" {
  principal_id                     = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_resource_group.node_resource_group.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks-subnet-contributer" {
  scope                = var.aks_subnet_id
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Network Contributor"
}

resource "azurerm_role_assignment" "aks-identity-operator" {
  scope                = azurerm_user_assigned_identity.aks_identity.id
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Managed Identity Operator"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                    = "${var.name}-aks"
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = "${var.name}-dns"
  kubernetes_version      = var.kubernetes_version
  private_cluster_enabled = true

  node_resource_group = "${var.name}-node-rg"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                         = "system"
    node_count                   = var.node_count
    vm_size                      = var.system_pool_vm_size
    zones                        = ["1", "2"]
    vnet_subnet_id               = var.aks_subnet_id #data.azurerm_subnet.akssubnet.id
    type                         = "VirtualMachineScaleSets"
    orchestrator_version         = var.kubernetes_version
    only_critical_addons_enabled = true
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.aks_identity.client_id
    object_id                 = azurerm_user_assigned_identity.aks_identity.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  tags = {
    Environment = "test"
  }

  #  addon_profile {
  oms_agent {
    log_analytics_workspace_id = var.diagnostics_workspace_id
  }

  ingress_application_gateway {
    subnet_id = var.apgw_subnet_id
  }
  #  }

  key_vault_secrets_provider {
    secret_rotation_enabled = false
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = [var.aks_admins_group_object_id]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user_pools" {
  lifecycle {
    ignore_changes = [
      node_count,
      tags
    ]
  }

  kubernetes_cluster_id  = azurerm_kubernetes_cluster.k8s.id
  name                   = "user"
  mode                   = "User"
  node_count             = 1
  vm_size                = var.user_pool_vm_size
  zones                  = ["1", "2"]
  max_pods               = 110
  os_disk_size_gb        = 128
  node_labels            = { nodepool : "user" }
  node_taints            = []
  enable_host_encryption = false
  enable_node_public_ip  = false
  fips_enabled           = false
  enable_auto_scaling    = false
  min_count              = 0
  max_count              = 0

  vnet_subnet_id = var.aks_subnet_id

  tags = {
    Environment = "dev"
  }

}

data "azurerm_resource_group" "node_resource_group" {
  name       = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

data "azurerm_public_ip" "public_ip" {
  name                = reverse(split("/", tolist(azurerm_kubernetes_cluster.k8s.network_profile.0.load_balancer_profile.0.effective_outbound_ips)[0]))[0]
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
}

resource "azurerm_key_vault" "main" {
  name                = format("%s-kv", lower(var.name))
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  enable_rbac_authorization       = true
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
}

resource "azurerm_role_assignment" "kv_role_admin_kva" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
  skip_service_principal_aad_check = true
}

data "azurerm_user_assigned_identity" "kv_secrets_provider" {
  name                = format("%s-%s", "azurekeyvaultsecretsprovider", azurerm_kubernetes_cluster.k8s.name)
  resource_group_name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on          = [azurerm_kubernetes_cluster.k8s]
}

resource "azurerm_role_assignment" "kv_secrets_provider" {
  scope                = azurerm_key_vault.main.id
  principal_id         = data.azurerm_user_assigned_identity.kv_secrets_provider.principal_id
  role_definition_name = "Key Vault Secrets User"
  skip_service_principal_aad_check = true
}

resource "azurerm_key_vault_secret" "secret" {
  key_vault_id = azurerm_key_vault.main.id
  name         = "demosecret"
  value        = "demovalue"
#  depends_on   = [azurerm_role_assignment.kv_role_admin_kva]
}


#az role assignment create --assignee-object-id $IDENTITY_ID --role "Key Vault Secrets User" --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RG/providers/Microsoft.KeyVault/vaults/$KV
