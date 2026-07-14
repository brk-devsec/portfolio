# =========================================
#  공통 변수
# =========================================
variable "prefix" {
  description = "모든 리소스 이름 앞에 붙는 팀 접두사"
  type        = string
  default     = "team602"
}

variable "location" {
  description = "리소스 배포 리전"
  type        = string
  default     = "KoreaCentral"
}

variable "rg_name" {
  description = "리소스 그룹 이름"
  type        = string
  default     = "team602-rg"
}

# =========================================
#  네트워크 변수
# =========================================
variable "vnet_cidr" {
  description = "메인 VNet 주소 공간"
  type        = string
  default     = "10.0.0.0/16"
}

variable "kali_vnet_cidr" {
  description = "공격자(Kali) 전용 VNet 주소 공간"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnets" {
  description = "메인 VNet 서브넷 (이름 => CIDR)"
  type        = map(string)
  default = {
    bastion = "10.0.0.0/24"
    web     = "10.0.3.0/24"
    db      = "10.0.5.0/24"
  }
}

variable "kali_subnet_cidr" {
  description = "Kali 서브넷 CIDR"
  type        = string
  default     = "10.10.10.0/24"
}

# =========================================
#  VM 변수
# =========================================
variable "vm_size" {
  description = "기본 VM 크기"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "VM 관리자 계정명"
  type        = string
  default     = "azureadmin"
}

variable "ssh_public_key_path" {
  description = "Bastion/Web/DB 접속용 SSH 공개키 경로"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

# =========================================
#  MariaDB (DB VM 내부 설치) 변수
# =========================================
variable "mysql_root_password" {
  description = "MariaDB root 비밀번호"
  type        = string
  default     = "ChangeMe_Root#2024"
  sensitive   = true
}

variable "mysql_app_user" {
  description = "WordPress용 MariaDB 계정명"
  type        = string
  default     = "wpuser"
}

variable "mysql_app_password" {
  description = "WordPress용 MariaDB 비밀번호"
  type        = string
  default     = "ChangeMe_App#2024"
  sensitive   = true
}

variable "mysql_database" {
  description = "WordPress 데이터베이스 이름"
  type        = string
  default     = "wordpress"
}

# =========================================
#  태그
# =========================================
variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default = {
    team    = "team602"
    project = "azure-data-app-security"
    phase   = "phase1"
  }
}

# =========================================
#  Bastion 관리자 IP
# =========================================
variable "admin_ip" {
  description = "Bastion SSH를 허용할 관리자 공인 IP (CIDR 또는 단일 IP). 예: 203.0.113.10/32"
  type        = string
  default     = "*"
}
