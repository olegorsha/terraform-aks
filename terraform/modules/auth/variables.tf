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