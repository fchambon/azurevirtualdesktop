terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.40.0"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "RG-INFRA-MGMT-WE"
    storage_account_name = "azstotf2023"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}