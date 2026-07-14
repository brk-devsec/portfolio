# =========================================================
#  34_keyvault_access_rule.tf
#  Key Vault 비정상 접근 탐지 규칙
#  [의존] 13_kv_diagnostics.tf → AzureDiagnostics (AuditEvent)
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "kv_access" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-kv-abnormal-access"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] Key Vault 다량 시크릿 조회 탐지"
  description                = "단시간 내 다량의 Key Vault 시크릿 조회(SecretGet) 또는 접근 거부(Forbidden)를 탐지한다."
  severity                   = "Medium"
  enabled                    = true

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["CredentialAccess"]
  techniques = ["T1552"]

  query = <<-KQL
    AzureDiagnostics
    | where ResourceType == "VAULTS"
    | where OperationName in ("SecretGet", "SecretList") or ResultSignature == "Forbidden"
    | extend Caller = coalesce(identity_claim_unique_name_s, CallerIPAddress, "unknown")
    | summarize AccessCount = count() by Caller, OperationName, Resource, bin(TimeGenerated, 10m)
    | where AccessCount > 10 or OperationName == "Forbidden"
  KQL

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "Caller"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = true
      lookback_duration       = "PT10M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}
