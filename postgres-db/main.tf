#
# Postgres test Private Endpoint
#

provider "azurerm" {
  features {}
}

resource "azurerm_postgresql_server" "pg" {
  name                = "postgresql-infra-test"
  location            = var.location
  resource_group_name = "${var.prefix}-datasql-rg"

  sku_name = "GP_Gen5_4"

  backup_retention_days         = 7
  geo_redundant_backup_enabled  = false
  public_network_access_enabled = true

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

# dig TXT +short o-o.myaddr.l.google.com @ns1.google.com
resource "azurerm_postgresql_firewall_rule" "pgfw" {
  name                = "moje-ip"
  resource_group_name = "${var.prefix}-datasql-rg"
  server_name         = azurerm_postgresql_server.pg.name
  start_ip_address    = "217.30.64.14"
  end_ip_address      = "217.30.64.14"
}

# postgres db
resource "azurerm_postgresql_database" "pgdb" {
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
}
