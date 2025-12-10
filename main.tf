# 1. Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Create the DEV Resource Group
resource "azurerm_resource_group" "rg_dev" {
  name     = "rg-gopal-dev"
  location = "East US"
}

# 3. Create the PROD Resource Group
resource "azurerm_resource_group" "rg_prod" {
  name     = "rg-gopal-prod"
  location = "East US"
}