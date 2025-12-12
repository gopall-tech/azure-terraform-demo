terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  # Backend Block for State File
  # We leave this empty here and fill the details in the Pipeline via -backend-config
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}

# --- DEV ENVIRONMENT ---

# 1. Dev Resource Group
resource "azurerm_resource_group" "rg_dev" {
  name     = "rg-gopal-dev"
  location = "East US"
}

# 2. Dev Networking
resource "azurerm_virtual_network" "vnet_dev" {
  name                = "vnet-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_dev.location
  resource_group_name = azurerm_resource_group.rg_dev.name
}

resource "azurerm_subnet" "subnet_dev" {
  name                 = "subnet-dev"
  resource_group_name  = azurerm_resource_group.rg_dev.name
  virtual_network_name = azurerm_virtual_network.vnet_dev.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic_dev" {
  name                = "nic-dev"
  location            = azurerm_resource_group.rg_dev.location
  resource_group_name = azurerm_resource_group.rg_dev.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_dev.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 3. Dev VM - Smaller Size (Standard_B1s)
resource "azurerm_linux_virtual_machine" "vm_dev" {
  name                = "vm-gopal-dev"
  resource_group_name = azurerm_resource_group.rg_dev.name
  location            = azurerm_resource_group.rg_dev.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_dev.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# --- PROD ENVIRONMENT ---

# 4. Prod Resource Group
resource "azurerm_resource_group" "rg_prod" {
  name     = "rg-gopal-prod"
  location = "East US"
}

# 5. Prod Networking
resource "azurerm_virtual_network" "vnet_prod" {
  name                = "vnet-prod"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name
}

resource "azurerm_subnet" "subnet_prod" {
  name                 = "subnet-prod"
  resource_group_name  = azurerm_resource_group.rg_prod.name
  virtual_network_name = azurerm_virtual_network.vnet_prod.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_interface" "nic_prod" {
  name                = "nic-prod"
  location            = azurerm_resource_group.rg_prod.location
  resource_group_name = azurerm_resource_group.rg_prod.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_prod.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 6. Prod VM - Larger Size (Standard_D2s_v3)
resource "azurerm_linux_virtual_machine" "vm_prod" {
  name                = "vm-gopal-prod"
  resource_group_name = azurerm_resource_group.rg_prod.name
  location            = azurerm_resource_group.rg_prod.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_prod.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
