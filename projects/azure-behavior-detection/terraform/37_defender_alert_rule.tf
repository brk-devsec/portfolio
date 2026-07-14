# =========================================================
#  37_defender_alert_rule.tf
#  Defender for Cloud 경고 연동 탐지 규칙
#  [의존] 09_monitor.tf Defender 커넥터 / 26_defender_export → SecurityAlert
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "defender_alert" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-defender-alert"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] Defender for Cloud 경고 연동"
  description                = "Defender for Cloud가 생성한 보안 경고(Brute Force 등)를 Sentinel 인시던트로 승격한다."
  severity                   = "High"
  enabled                    = true

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["InitialAccess"]
  techniques = ["T1190"]

  query = <<-KQL
    SecurityAlert
    | where ProductName has "Azure Security Center" or ProductName has "Microsoft Defender for Cloud"
    | extend HostName = tostring(parse_json(Entities)[0].HostName)
    | summarize AlertCount = count() by AlertName, AlertSeverity, CompromisedEntity, bin(TimeGenerated, 5m)
  KQL

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "CompromisedEntity"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = true
      lookback_duration       = "PT5M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}
