# =========================================================
#  22_web_attack_rule.tf
#  Sentinel 웹 공격 탐지 분석 규칙
#  - Apache access 로그(local5, ProcessName=apache-access)를 대상
#  - 웹 스캐너/공격 도구 및 SQLi/XSS 패턴 탐지
#
#  [의존] azurerm_log_analytics_workspace.main
#         azurerm_sentinel_log_analytics_workspace_onboarding.main
#  [선행] web_init 의 syslog-logging.conf 로 Apache 로그가 local5 로 수집되어야 함
# =========================================================

# ---------------------------------------------------------
# 규칙 4) 웹 공격 도구/스캐너 탐지
#   - User-Agent 또는 요청에 알려진 공격 도구 문자열
#   - Phase1 검증: nikto, sqlmap, wpscan 등
# ---------------------------------------------------------
resource "azurerm_sentinel_alert_rule_scheduled" "web_scanner" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-web-scanner"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] 웹 공격 도구/스캐너 탐지"
  description                = "Apache 접근 로그에서 알려진 웹 공격 도구(nikto/sqlmap/wpscan 등)의 요청을 탐지한다."
  severity                   = "Medium"
  enabled                    = true

  query_frequency = "PT5M"
  query_period    = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["Reconnaissance", "InitialAccess"]
  techniques = ["T1595", "T1190"] # Active Scanning, Exploit Public-Facing App

  query = <<-KQL
    Syslog
    | where Facility == "local5"
    | where ProcessName == "apache-access"
    | where SyslogMessage has_any ("sqlmap", "nikto", "wpscan", "nmap", "masscan", "dirbuster", "gobuster", "hydra")
    | extend AttackerIP = extract(@"^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})", 1, SyslogMessage)
    | where isnotempty(AttackerIP)
    | summarize HitCount = count() by AttackerIP, Computer, bin(TimeGenerated, 5m)
    | extend IPCustomEntity = AttackerIP, HostCustomEntity = Computer
  KQL

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }
  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
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

# ---------------------------------------------------------
# 규칙 5) SQL Injection / XSS 페이로드 탐지
#   - 요청 URI에 SQLi/XSS 공격 패턴
# ---------------------------------------------------------
resource "azurerm_sentinel_alert_rule_scheduled" "web_injection" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-web-injection"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] 웹 인젝션(SQLi/XSS) 시도 탐지"
  description                = "Apache 접근 로그에서 SQL Injection 또는 XSS 공격 패턴을 포함한 요청을 탐지한다."
  severity                   = "High"
  enabled                    = true

  query_frequency = "PT5M"
  query_period    = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["InitialAccess"]
  techniques = ["T1190"]

  query = <<-KQL
    Syslog
    | where Facility == "local5"
    | where ProcessName == "apache-access"
    | where SyslogMessage has_any ("UNION SELECT", "union+select", "OR 1=1", "or+1=1", "SLEEP(", "WAITFOR DELAY", "<script>", "%3Cscript", "information_schema", "xp_cmdshell", "/etc/passwd", "../..")
    | extend AttackerIP = extract(@"^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})", 1, SyslogMessage)
    | where isnotempty(AttackerIP)
    | summarize AttackCount = count() by AttackerIP, Computer, bin(TimeGenerated, 5m)
    | extend IPCustomEntity = AttackerIP, HostCustomEntity = Computer
  KQL

  entity_mapping {
    entity_type = "IP"
    field_mapping {
      identifier  = "Address"
      column_name = "AttackerIP"
    }
  }
  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
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
