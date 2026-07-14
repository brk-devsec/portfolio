# =========================================================
#  36_governance_change_rule.tf
#  거버넌스 변경 탐지 규칙 (역할/정책/NSG 변경)
#  [의존] 09_monitor.tf Activity Log → AzureActivity
#  * 19_governance_detect.tf의 activity_log_alert(이메일)와 별개로,
#    Sentinel 인시던트로 생성하기 위한 분석 규칙
# =========================================================
resource "azurerm_sentinel_alert_rule_scheduled" "governance_change" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-governance-change"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] 권한/정책/NSG 변경 탐지"
  description                = "역할 할당, Azure Policy, NSG 규칙 변경 등 거버넌스 관련 변경 작업을 탐지한다."
  severity                   = "Medium"
  enabled                    = true

  query_frequency   = "PT10M"
  query_period      = "PT10M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["PrivilegeEscalation", "Persistence"]
  techniques = ["T1098", "T1078"]

  query = <<-KQL
    AzureActivity
    | where OperationNameValue has_any (
        "roleAssignments/write", "roleAssignments/delete",
        "policyAssignments/write",
        "networkSecurityGroups/securityRules/write",
        "networkSecurityGroups/securityRules/delete"
      )
    | where ActivityStatusValue in ("Success", "Accept", "Started")
    | extend Actor = coalesce(Caller, "unknown")
    | summarize ChangeCount = count() by Actor, OperationNameValue, CallerIpAddress, bin(TimeGenerated, 10m)
  KQL

  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "Actor"
    }
  }
  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "CallerIpAddress"
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
