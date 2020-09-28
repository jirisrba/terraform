#
# Postgres test Private Endpoint
#

provider "azurerm" {
  features {}
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = "${var.prefix}-net-rg"

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

resource "azurerm_subnet" "internal" {
  name                                           = "${var.prefix}-subnet-service"
  resource_group_name                            = "${var.prefix}-net-rg"
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.1.0/24"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

# postgres endpoint
resource "azurerm_subnet" "endpoint" {
  name                                           = "${var.prefix}-subnet-endpoint"
  resource_group_name                            = "${var.prefix}-net-rg"
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  address_prefixes                               = ["10.0.2.0/24"]
  enforce_private_link_endpoint_network_policies = true
  enforce_private_link_service_network_policies  = true
}

resource "azurerm_network_security_group" "sg" {
  name                = "allow-ssh"
  location            = var.location
  resource_group_name = "${var.prefix}-sec-rg"

  security_rule {
    name                       = "allow-ssh"
    priority                   = 330
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  sku                 = "Standard"
  location            = var.location
  resource_group_name = "${var.prefix}-net-rg"
  allocation_method   = "Static"

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

## resource "azurerm_firewall" "test_fw" {
##   name                = "testfirewall"
##   location            = var.location
##   resource_group_name = "${var.prefix}-net-rg"
##
##   ip_configuration {
##     name                 = "configuration"
##     subnet_id            = azurerm_subnet.internal.id
##     public_ip_address_id = azurerm_public_ip.pip.id
##   }
## }

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  resource_group_name = "${var.prefix}-net-rg"
  location            = var.location


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.sg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = "${var.prefix}-complin-rg"
  location                        = var.location
  size                            = "Standard_F2"
  admin_username                  = "admin"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "admin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

resource "azurerm_virtual_machine_extension" "aptpg" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "apt-get install -y postgresql-client"
    }
SETTINGS

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

resource "azurerm_postgresql_server" "pg" {
  name                = "postgresql-infra-test"
  location            = var.location
  resource_group_name = "${var.prefix}-datasql-rg"

  sku_name = "GP_Gen5_4"

  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = false

  administrator_login          = "postgres"
  administrator_login_password = "Abcd1234"

  version                          = "11"
  ssl_enforcement_enabled          = true
  ssl_minimal_tls_version_enforced = "TLS1_2"

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

## resource "azurerm_postgresql_firewall_rule" "fw" {
##   name                = "office"
##   resource_group_name = "${var.prefix}-datasql-rg"
##   server_name         = azurerm_postgresql_server.pg.name
##   start_ip_address    = "89.24.45.0"
##   end_ip_address      = "89.24.45.255"
## }

# PrivateE
resource "azurerm_private_endpoint" "pe" {
  name                = "${var.prefix}-pe"
  location            = var.location
  resource_group_name = "${var.prefix}-net-rg"
  subnet_id           = azurerm_subnet.endpoint.id

  private_service_connection {
    name                           = "${var.prefix}-privatee"
    private_connection_resource_id = azurerm_postgresql_server.pg.id
    subresource_names              = ["postgresqlServer"]
    is_manual_connection           = false
  }

  tags = {
    GLOBAL-Environment = "SANDBOX"
    GLOBAL-SAS         = "SAS_PGDBF"
    GLOBAL-Squad       = "A841_14"
    GLOBAL-Tribe       = "A841"
  }
}

# postgres db
resource "azurerm_postgresql_database" "db" {
  name                = "azuretest"
  resource_group_name = "${var.prefix}-datasql-rg"
  server_name         = azurerm_postgresql_server.pg.name
  charset             = "UTF8"
  collation           = "English_United States.1252"
}

# Azure pgAudit
resource "azurerm_postgresql_configuration" "shared_preload_libraries" {
  name                = "shared_preload_libraries"
  resource_group_name = "${var.prefix}-datasql-rg"
  server_name         = azurerm_postgresql_server.pg.name
  value               = "pgaudit"

  provisioner "local-exec" {
    command = <<EOC
      az postgres server restart \
      --name ${azurerm_postgresql_server.pg.name} \
      --resource-group ${var.prefix}-datasql-rg
EOC
  }
}

resource "azurerm_postgresql_configuration" "pgaudit_ddl" {
  name                = "pgaudit.log"
  resource_group_name = "${var.prefix}-datasql-rg"
  server_name         = azurerm_postgresql_server.pg.name
  value               = "DDL"

  provisioner "local-exec" {
    command = <<EOC
      az postgres server restart \
      --name ${azurerm_postgresql_server.pg.name} \
      --resource-group ${var.prefix}-datasql-rg
EOC
  }
}
