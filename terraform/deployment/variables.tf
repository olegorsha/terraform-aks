variable "name" {
  type        = string
  description = "Name for resources"
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Azure Location of resources"
}

variable "network_address_space" {
  type        = string
  description = "Azure VNET Address Space"
}

variable "aks_subnet_address_name" {
  type        = string
  description = "AKS Subnet Address Name"
}

variable "aks_subnet_address_prefix" {
  type        = string
  description = "AKS Subnet Address Space"
}

variable "appgw_subnet_address_name" {
  type        = string
  description = "AppGW Subnet Address Name"
}

variable "appgw_subnet_address_prefix" {
  type        = string
  description = "AppGW Subnet Address Space"
}

variable "public_subnet_address_name" {
  type        = string
  description = "Public Subnet Address Name"
}

variable "public_subnet_address_prefix" {
  type        = string
  description = "AppGW Subnet Address Space"
}

variable "bastion_subnet_address_prefix" {
  type        = string
  description = "Bastion Subnet Address Space"
}

variable "services_subnet_address_name" {
  type        = string
  description = "Services Subnet Address Name"
}

variable "services_subnet_address_prefix" {
  type        = string
  description = "Services Subnet Address Space"
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