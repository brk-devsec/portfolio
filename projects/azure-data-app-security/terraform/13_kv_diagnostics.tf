# =========================================================
#  18_kv_diagnostics.tf — 묶음 A: Key Vault 접근 로그 수집
#
#  목적: 시크릿/키 Get·List·Set·Delete 같은 실제 접근 기록을
#        기존 Log Analytics Workspace(09_monitor.tf)로 전송.
#
#  ★ 참고: 인증 모델(RBAC vs Access Policy)과는 무관한 설정입니다.
#    Diagnostic Setting을 추가하지 않으면 어떤 인증 모델을 쓰든
#    접근 로그는 저장되지 않습니다.
#
#  조회 방법 (Log Analytics 포털 > Logs):
#    AzureDiagnostics
#    | where ResourceType == "VAULTS"
#    | where OperationName in ("SecretGet", "SecretList", "SecretSet", "SecretDelete")
#    | project TimeGenerated, OperationName, identity_claim_upn_s, ResourceId, ResultType
# =========================================================

# --- a_main (10_keyvault.tf) : DB 자격증명 시크릿 저장소 ---
resource "azurerm_monitor_diagnostic_setting" "a_kv_main_diag" {
  name                       = "${var.prefix}-kv-main-diag"
  target_resource_id         = azurerm_key_vault.a_main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }
}

# --- a_des_kv (12_disk_encryption.tf) : 디스크 암호화 키 전용 KV ---
resource "azurerm_monitor_diagnostic_setting" "a_kv_des_diag" {
  name                       = "${var.prefix}-kv-des-diag"
  target_resource_id         = azurerm_key_vault.a_des_kv.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AuditEvent"
  }
}
