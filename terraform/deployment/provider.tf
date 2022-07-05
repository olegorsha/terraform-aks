terraform {
  required_version = ">=1.2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.11.0"
      # use_msi = true
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=2.24.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.0.1"
    }
  }

  backend "azurerm" {
    storage_account_name = "fdkstorage"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    resource_group_name  = "fdk-storage-rg"
  }
}

provider "azuread" {
  # tenant_id = "00000000-0000-0000-0000-000000000000"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "random" {
}
