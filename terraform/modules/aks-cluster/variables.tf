variable "name" {
  type        = string
  description = "Name for resources"
}

variable "location" {
  type        = string
  description = "Azure Location of resources"
}

variable "resource_group_name" {
  type        = string
  description = "resource group that the vnet resides in"
}

# variable "vnet_id" {
#   type        = string
#   description = "Azure VNET Address Space"
# }

variable aks_subnet_id {
  description = "ID of subnet where aks will be installed"
  type        = string
}

variable apgw_subnet_id {
  description = "ID of subnet where app gw will be installed"
  type        = string
}

variable diagnostics_workspace_id {
  description = "ID of workpace where log analitics will be installed"
  type        = string
}

#variable "addons" {
#  description = "Defines which addons will be activated."
#  type = object({
#    oms_agent                   = bool
#    ingress_application_gateway = bool
#  })
#}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}

variable "kubernetes_version" {
}

variable "node_count" {
}

variable "system_pool_vm_size" {
  default = "Standard_B2ms"
}

variable "user_pool_vm_size" {
  default = "Standard_A2m_v2"
}

variable "ssh_public_key" {
}

variable "aks_admins_group_object_id" {
}