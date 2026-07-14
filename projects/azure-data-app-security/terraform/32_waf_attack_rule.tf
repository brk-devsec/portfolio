# =========================================================
#  32_waf_attack_rule.tf
#  WAF(Application Gateway) 차단 로그 기반 탐지 규칙
#  [의존] 23_waf.tf의 diagnostic_setting → AzureDiagnostics
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "waf_attack" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-waf-attack"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] WAF 웹 공격 차단 탐지"
  description                = "Application Gateway WAF가 매칭·차단한 웹 공격(OWASP CRS 룰 위반)을 탐지한다."
  severity                   = "High"
  enabled                    = true

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["InitialAccess"]
  techniques = ["T1190"]

  query = <<-KQL
    AzureDiagnostics
    | where Category == "ApplicationGatewayFirewallLog"
    | where action_s in ("Matched", "Blocked")
    | extend AttackerIP = clientIp_s
    | where isnotempty(AttackerIP)
    | summarize HitCount = count(), Rules = make_set(ruleId_s) by AttackerIP, requestUri_s, bin(TimeGenerated, 5m)
  KQL

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
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
