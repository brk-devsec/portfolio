terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

/*
# =========================================
#  Marketplace 약관 동의
#  이미 동의된 상태면 에러 → import로 해결:
#  terraform import azurerm_marketplace_agreement.rocky resf:rockylinux-x86_64:9-lvm
#  terraform import azurerm_marketplace_agreement.kali kali-linux:kali:kali-2025-3
# =========================================
resource "azurerm_marketplace_agreement" "rocky" {
  publisher = "resf"
  offer     = "rockylinux-x86_64"
  plan      = "9-lvm"
}

resource "azurerm_marketplace_agreement" "kali" {
  publisher = "kali-linux"
  offer     = "kali"
  plan      = "kali-2025-3"
}
*/
