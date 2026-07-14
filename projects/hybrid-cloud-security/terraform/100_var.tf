variable "rgname_central" {
  type    = string
  default = "team601-central-rg"
}

variable "rgname_japan" {
  type    = string
  default = "team601-japan-rg"
}

variable "loca" {
  type    = string
  default = "KoreaCentral"
}

variable "loca_japan" {
  type    = string
  default = "JapanEast"
}

variable "admin_username" {
  type    = string
  default = "ijo"
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "vpn_psk" {
  type      = string
  default   = "It12345@"
  sensitive = true
}