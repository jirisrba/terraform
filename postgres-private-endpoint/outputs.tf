output "vm_public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

output "postgres_fqdn" {
  value = azurerm_postgresql_server.pg.fqdn
}
