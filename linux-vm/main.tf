# terraform {
#   backend "remote" {
#     hostname = "app.terraform.io"
#     organization = "operatorict"
#
#     workspaces {
#       name = "portalprazana"
#     }
#   }
# }

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.vm_name}-${var.environment}"
  location = var.location

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.vm_name}"
  resource_group_name  = "grp-${var.environment}-vnet"
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.10.8.0/23"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.virtual_network_name}-${var.vm_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                        = "ssh"
    priority                    = "100"
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }

  tags = {
    environment = var.environment
  }
}

resource "azurerm_subnet_network_security_group_association" "vm" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "vm-${var.vm_name}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = var.environment
  }
}

#resource "azurerm_linux_virtual_machine" "main" {
#  name                            = "${var.prefix}-vm"
#  resource_group_name             = "rg-complin-rg"
#  location                        = var.location
#  size                            = "Standard_F2"
#  admin_username                  = "adminuser"
#  admin_password                  = "P@ssw0rd1234!"
#  disable_password_authentication = false
#  network_interface_ids = [
#    azurerm_network_interface.nic.id,
#  ]
#
#  admin_ssh_key {
#    username   = "adminuser"
#    public_key = file("~/.ssh/id_rsa.pub")
#  }
#
#  os_disk {
#    caching              = "ReadWrite"
#    storage_account_type = "Standard_LRS"
#  }
#
#  source_image_reference {
#    publisher = "Canonical"
#    offer     = "UbuntuServer"
#    sku       = "16.04-LTS"
#    version   = "latest"
#  }
#}
