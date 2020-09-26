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

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.vm_name}-lab"
  location = var.location

  tags = {
    environment = "lab"
  }
}

resource "azurerm_dev_test_lab" "lab" {
  name                = "${var.vm_name}-devtestlab"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

}


resource "azurerm_dev_test_virtual_network" "net" {
  name                = "vnet-lab"
  lab_name            = azurerm_dev_test_lab.lab.name
  resource_group_name = azurerm_resource_group.rg.name

  subnet {
    use_public_ip_address           = "Allow"
    use_in_virtual_machine_creation = "Allow"
  }
}

resource "azurerm_dev_test_linux_virtual_machine" "vm" {
  name                   = "vm-${var.vm_name}-lab"
  lab_name               = azurerm_dev_test_lab.lab.name
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  size                   = "Standard_B2S"
  username               = "adminuser"
  ssh_key                = file("~/.ssh/id_rsa.pub")
  lab_virtual_network_id = azurerm_dev_test_virtual_network.net.id
  lab_subnet_name        = azurerm_dev_test_virtual_network.net.subnet[0].name
  storage_type           = "Premium"
  notes                  = "To je moje Virtual Machine."

  gallery_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

# resource "azurerm_virtual_machine_extension" "vme" {
#   name                 = "hostname"
#   virtual_machine_id   = azurerm_dev_test_linux_virtual_machine.vm.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"
#
#   settings = <<SETTINGS
#     {
#         "commandToExecute": "hostname && uptime"
#     }
# SETTINGS
#
#   tags = {
#     environment = "lab"
#   }
# }
