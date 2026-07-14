# =========================================================
#  33_firewall_exfil_rule.tf
#  Azure Firewall Deny 로그 기반 데이터 유출 탐지 규칙
#  [의존] 24_firewall.tf의 diagnostic_setting → AzureDiagnostics
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "firewall_exfil" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-firewall-exfil"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] Firewall 아웃바운드 차단(유출 시도) 탐지"
  description                = "Azure Firewall이 Deny한 아웃바운드 트래픽(데이터 유출 시도 등)을 탐지한다."
  severity                   = "High"
  enabled                    = true

  query_frequency   = "PT5M"
  query_period      = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["Exfiltration"]
  techniques = ["T1048"]

  query = <<-KQL
    AzureDiagnostics
    | where ResourceType == "AZUREFIREWALLS"
    | where Category in ("AzureFirewallNetworkRule", "AZFWNetworkRule")
    | where msg_s has "Deny" or msg_s has "Denied"
    | extend SrcIP = extract(@"from ([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})", 1, msg_s)
    | where isnotempty(SrcIP)
    | summarize HitCount = count() by SrcIP, msg_s, bin(TimeGenerated, 5m)
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
      enabled                 = true
      lookback_duration       = "PT5M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}
