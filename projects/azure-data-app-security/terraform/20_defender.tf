# ============================================================
# 13_defender.tf — Defender for Cloud 워크로드 보호 플랜 활성화
# 묶음 B / 리소스 라벨 접두사: b_
#
# 목적: VM·스토리지·Key Vault 등 핵심 워크로드를 Defender로 보호.
#       Phase 2 보안 점수 기준선 확보, JIT(14_jit.tf)의 선행 조건.
#
# lifecycle { ignore_changes = all } 추가:
#   Defender 플랜은 구독 레벨 리소스라 terraform destroy로 삭제되지 않음.
#   매번 apply 시 충돌 방지를 위해 이미 존재하면 그냥 넘어가도록 설정.
# ============================================================


# ── Defender for Servers (Plan 1) ─────────────────────────────
# Student 구독은 P2 미지원 → subplan = "P1" 고정.
resource "azurerm_security_center_subscription_pricing" "b_vm" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
  subplan       = "P2"

  lifecycle {
    ignore_changes = all
  }
}

# ── Defender for Storage ──────────────────────────────────────
resource "azurerm_security_center_subscription_pricing" "b_storage" {
  tier          = "Standard"
  resource_type = "StorageAccounts"

  lifecycle {
    ignore_changes = all
  }
}

# ── Defender for Key Vault ────────────────────────────────────
resource "azurerm_security_center_subscription_pricing" "b_keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"

  lifecycle {
    ignore_changes = all
  }
}

# ── Defender for ARM ──────────────────────────────────────────
resource "azurerm_security_center_subscription_pricing" "b_arm" {
  tier          = "Standard"
  resource_type = "Arm"

  lifecycle {
    ignore_changes = all
  }
}

# ── Defender CSPM ─────────────────────────────────────────────
resource "azurerm_security_center_subscription_pricing" "b_cspm" {
  tier          = "Standard"
  resource_type = "CloudPosture"

  lifecycle {
    ignore_changes = all
  }
}

# ── Defender 보안 담당자 연락처 ──────────────────────────────────
resource "azurerm_security_center_contact" "b_contact" {
  name  = "team602-contact"
  email = "bnmil8274@gmail.com"

  alert_notifications = true
  alerts_to_admins    = true

  lifecycle {
    ignore_changes = all
  }
}
