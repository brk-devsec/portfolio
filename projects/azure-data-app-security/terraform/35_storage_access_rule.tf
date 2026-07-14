# =========================================================
#  35_storage_access_rule.tf
#  스토리지 비인가 접근 탐지 규칙
#  [의존] 15_storage_diagnostics.tf → StorageBlobLogs
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "storage_access" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-storage-unauthorized"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] 스토리지 비인가/실패 접근 탐지"
  description                = "Blob 스토리지에 대한 인증 실패(403) 또는 비정상 접근을 탐지한다."
  severity                   = "Medium"
  enabled                    = true

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["Collection"]
  techniques = ["T1530"]

  query = <<-KQL
    StorageBlobLogs
    | where StatusCode in (403, 401) or AuthenticationType == "Anonymous"
    | extend SrcIP = tostring(split(CallerIpAddress, ":")[0])
    | where isnotempty(SrcIP)
    | summarize FailCount = count() by SrcIP, OperationName, StatusText, bin(TimeGenerated, 10m)
  KQL

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "SrcIP"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = false
      lookback_duration       = "PT10M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}
