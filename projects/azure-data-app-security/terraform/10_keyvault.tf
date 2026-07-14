# =========================================================
#  10_keyvault.tf — 독립 검증용 (standalone)
#
#  통합 시 변경 사항:
#    - azurerm_resource_group.rg → 기존 team602-rg 참조로 교체
#    - Secret value를 var.mysql_* 에서 하드코딩(예: "<password>")으로 교체하거나
#      tfvars를 그대로 유지
#    - provider.tf / variables.tf / rg.tf / outputs.tf 는 삭제하고
#      기존 00_provider.tf / 01_variables.tf / 02_rg.tf 에 합류
# =========================================================

# 현재 Terraform 실행 주체(서비스 프린시펄 또는 사용자) 정보 조회
data "azurerm_client_config" "current" {}

# Key Vault 이름은 전 세계 유니크 필요 → 6자 랜덤 suffix
resource "random_string" "a_kv" {
  length  = 6
  special = false
  upper   = false
}

# -------------------------------------------------------
#  Key Vault 본체 — RBAC 권한 모델
# -------------------------------------------------------
resource "azurerm_key_vault" "a_main" {
  name                = "${var.prefix}-kv-${random_string.a_kv.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = false
  soft_delete_retention_days = 7

  # 12_disk_encryption.tf는 별도 KV(a_des_kv)를 사용하므로 이 KV의
  # purge_protection과는 무관 (false 유지)
  purge_protection_enabled = false

  # ★ access_policy는 이 리소스에 inline으로 넣지 않고 11_managed_identity.tf에서
  #   azurerm_key_vault_access_policy 리소스로 일괄 관리합니다.
  #   (inline access_policy 블록과 standalone 리소스를 같은 Key Vault에 함께 쓰면
  #    AzureRM에서 정책 목록 충돌이 발생할 수 있어 방식을 하나로 통일했습니다.)

  tags = var.tags
}

# -------------------------------------------------------
#  Terraform 실행 주체 → Key Vault: Secret 쓰기 권한
#  RBAC 모델에서는 생성자에게도 별도 권한 할당 필요
#  구독 레벨 문제로 주석처리하고 azure포탈에서 직접 생성 예정
# -------------------------------------------------------
/* resource "azurerm_role_assignment" "a_kv_admin_secret" {
  scope                = azurerm_key_vault.a_main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
} */    

# -------------------------------------------------------
#  시크릿 저장 — DB 자격증명
#  Phase 1에서 wp-config.php에 평문 노출되던 값을 KV로 이전
# -------------------------------------------------------
resource "azurerm_key_vault_secret" "a_db_root_pw" {
  name         = "db-root-password"
  value        = var.mysql_root_password
  key_vault_id = azurerm_key_vault.a_main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.a_self_kv]
}

resource "azurerm_key_vault_secret" "a_db_app_pw" {
  name         = "db-app-password"
  value        = var.mysql_app_password
  key_vault_id = azurerm_key_vault.a_main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.a_self_kv]
}

resource "azurerm_key_vault_secret" "a_db_app_user" {
  name         = "db-app-user"
  value        = var.mysql_app_user
  key_vault_id = azurerm_key_vault.a_main.id
  tags         = var.tags

  depends_on = [azurerm_key_vault_access_policy.a_self_kv]
}
