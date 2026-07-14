# =========================================================
#  11_managed_identity.tf — 묶음 A: VM → Key Vault 접근 권한
#
#  Access Policy 모델로 전환 (RBAC Role Assignment 대신)
#  Contributor 권한으로 가능
# =========================================================

# Terraform 실행 주체(본인) → Key Vault Secret 쓰기/관리 권한
# (10_keyvault.tf의 inline access_policy를 대체 — 방식 통일)
resource "azurerm_key_vault_access_policy" "a_self_kv" {
  key_vault_id = azurerm_key_vault.a_main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
}

# Web VM Managed Identity → Key Vault Secret 읽기
resource "azurerm_key_vault_access_policy" "a_web_kv" {
  key_vault_id = azurerm_key_vault.a_main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.web.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

# DB VM Managed Identity → Key Vault Secret 읽기
resource "azurerm_key_vault_access_policy" "a_db_kv" {
  key_vault_id = azurerm_key_vault.a_main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.db.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

# Bastion VM Managed Identity → Key Vault Secret 읽기
resource "azurerm_key_vault_access_policy" "a_bastion_kv" {
  key_vault_id = azurerm_key_vault.a_main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_linux_virtual_machine.bastion.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}