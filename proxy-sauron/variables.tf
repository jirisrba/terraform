variable "environment" {
  description = "Environment"
  default     = "prod"
}

variable "vm_name" {
  description = "The name of VM"
  default     = "proxy-sauron"
}

variable "location" {
  type    = string
  default = "West Europe"
}
