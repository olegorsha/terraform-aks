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
  description = "Public Subnet Address Space"
}

variable "services_subnet_address_name" {
  type        = string
  description = "Services Subnet Address Name"
}

variable "services_subnet_address_prefix" {
  type        = string
  description = "Services Subnet Address Space"
}