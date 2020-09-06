variable "environment" {
 description = "Environment"
 default = "dev"
}

variable "vm_name" {
 description = "The name of VM"
 default = "moje"
}

variable "virtual_network_name" {
 description = "The name of VM"
 default = "spokeDevVnet"
}

variable "location" {
  type    = string
  default = "West Europe"
}
