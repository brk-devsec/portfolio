variable "rgname_central" {
  type    = string
  default = "team601-central-rg2"
}

variable "rgname_japan" {
  type    = string
  default = "team601-japan-rg2"
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
  default   = "YOUR_VPN_PSK_HERE"  # ⚠️ 실제 PSK는 환경변수 또는 tfvars로 관리하세요
  sensitive = true
}

