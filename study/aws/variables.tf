variable "ssh_public_key_path" {
  description = "SSH 공개키 파일 경로"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "db_username" {
  description = "RDS MySQL 관리자 계정"
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "RDS MySQL 비밀번호 (terraform.tfvars에서 설정)"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "WordPress용 데이터베이스 이름"
  type        = string
  default     = "word"
}
