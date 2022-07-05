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

variable "vnet_id" {
  type        = string
  description = "Azure VNET Address Space"
}

variable subnet_id {
  description = "ID of subnet where jumpbox VM will be installed"
  type        = string
}

variable vm_user {
  description = "Jumpbox VM user name"
  type        = string
  default     = "azureadmin"
}