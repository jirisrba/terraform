variable "environment" {
  description = "Environment"
  default     = "dev"
}

variable "vm_name" {
  description = "The name of VM"
  default     = "moje"
}

variable "virtual_network_name" {
  description = "The name of VM"
  default     = "spokeDevVnet"
}

variable "my_public_ip" {
  default = "217.30.64.14"
}

variable "location" {
  type    = string
  default = "West Europe"
}
