terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}


provider "azurerm" {
  features {}
}

terraform {
  backend "remote" {
    organization = "operatorict"
    #
    workspaces {
      name = "portalprazana"
    }
  }
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
    name                       = "ssh"
    priority                   = "100"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
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

#resource "azurerm_linux_virtual_machine" "vm" {
#  name                            = "vm-${var.vm_name}-${var.environment}"
#  resource_group_name             = azurerm_resource_group.rg.name
#  location                        = azurerm_resource_group.rg.location
#  vm_size                         = "Standard_B2s"
#  network_interface_ids = [azurerm_network_interface.nic.id]
#
#  admin_ssh_key {
#    username   = "adminuser"
#    public_key = file("~/.ssh/id_rsa.pub")
#  }
#
#  storage_os_disk {
#    caching              = "ReadWrite"
#    create_option        = "FromImage"
#    storage_account_type = "Standard_LRS"
#  }
#
#  storage_image_reference {
#    publisher = "Canonical"
#    offer     = "UbuntuServer"
#    sku       = "16.04-LTS"
#    version   = "latest"
#  }
#
#  os_profile {
#    computer_name  = "${var.vm_name}"
#    admin_username = "azureuser"
#    admin_password = "P@ssw0rd1234!"
#  }
#
#  os_profile_linux_config {
#    disable_password_authentication = false
#  }
#
#  tags = {
#    environment = var.environment
#  }
#}

# data "azurerm_public_ip" "ip" {
#   name                = azurerm_public_ip.publicip.name
#   resource_group_name = azurerm_virtual_machine.vm.resource_group_name
#   depends_on          = [azurerm_virtual_machine.vm]
# }
