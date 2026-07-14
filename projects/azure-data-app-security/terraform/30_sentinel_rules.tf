# =========================================================
#  17_sentinel_rules.tf
#  Sentinel 예약 분석 규칙 (Scheduled Analytics Rules)
#  - Phase 1에서 검증된 로그 기반 자동 탐지 규칙
#  - 규칙 충족 시 인시던트(Incident) 자동 생성
#
#  [담당] Sentinel/NSG 통합 담당
#  [의존] azurerm_log_analytics_workspace.main
#         azurerm_sentinel_log_analytics_workspace_onboarding.main
# =========================================================

# ---------------------------------------------------------
# 규칙 1) SSH Brute Force 탐지
#   - sshd 로그에서 동일 IP의 로그인 실패가 단시간 다수 발생
#   - Phase1 검증 로그: "Failed password", "Invalid user"
# ---------------------------------------------------------
resource "azurerm_sentinel_alert_rule_scheduled" "ssh_bruteforce" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-ssh-bruteforce"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] SSH Brute Force 탐지"
  description                = "동일 출발지 IP에서 5분 내 SSH 로그인 실패가 10회를 초과하면 탐지한다."
  severity                   = "Medium"
  enabled                    = true

  query_frequency = "PT5M"  # 5분마다 실행
  query_period    = "PT5M"  # 최근 5분 구간 평가
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["CredentialAccess"]
  techniques = ["T1110"]  # Brute Force

  query = <<-KQL
    Syslog
    | where ProcessName == "sshd"
    | where SyslogMessage has_any ("Failed password", "Invalid user", "authentication failure")
    | extend AttackerIP = extract(@"from (?:invalid user \w+ )?([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})", 1, SyslogMessage)
    | where isnotempty(AttackerIP)
    | summarize FailCount = count() by AttackerIP, Computer, bin(TimeGenerated, 5m)
    | where FailCount > 10
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
# 규칙 2) 민감정보(personal_info) 대량 조회/유출 탐지
#   - MariaDB server_audit(local6)에서 personal_info 테이블 접근
#   - Phase1 검증 로그: "SELECT * FROM personal_info", "SQL_NO_CACHE ... personal_info"
# ---------------------------------------------------------
resource "azurerm_sentinel_alert_rule_scheduled" "db_sensitive_read" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-db-sensitive-read"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] 민감정보 테이블 접근/유출 탐지"
  description                = "MariaDB 감사 로그에서 personal_info 테이블에 대한 조회·덤프 행위를 탐지한다."
  severity                   = "High"
  enabled                    = true

  query_frequency = "PT5M"
  query_period    = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["Collection", "Exfiltration"]
  techniques = ["T1005", "T1041"]  # Data from Local System / Exfiltration

  query = <<-KQL
    Syslog
    | where Facility == "local6"
    | where SyslogMessage has "personal_info"
    | where SyslogMessage has_any ("SELECT", "SQL_NO_CACHE", "READ")
    | extend DBUser = extract(@"db-vm,(\w+),", 1, SyslogMessage)
    | summarize AccessCount = count() by Computer, DBUser, bin(TimeGenerated, 5m)
    | where AccessCount > 0
  KQL

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "DBUser"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = false
      lookback_duration       = "PT5M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}

# ---------------------------------------------------------
# 규칙 3) DB 권한 변경 / 계정 생성 시도 탐지
#   - 계정 탈취 후 권한 상승·백도어 계정 생성 시도
#   - Phase1 검증 로그: "CREATE USER", "GRANT", "ALTER USER", "DROP USER"
#   - 성공/거부(error 1227 등) 모두 탐지 대상 (시도 자체가 침해 지표)
# ---------------------------------------------------------
resource "azurerm_sentinel_alert_rule_scheduled" "db_privilege_change" {
  depends_on                 = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
  name                       = "team602-db-privilege-change"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  display_name               = "[team602] DB 권한 변경/계정 생성 시도 탐지"
  description                = "MariaDB에서 계정 생성·권한 변경 명령(CREATE USER, GRANT 등)을 탐지한다. 정상 애플리케이션 동작에서는 발생하지 않는 행위로 침해 지표에 해당한다."
  severity                   = "High"
  enabled                    = true

  query_frequency = "PT5M"
  query_period    = "PT5M"
  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  tactics    = ["PrivilegeEscalation", "Persistence"]
  techniques = ["T1078", "T1136"]  # Valid Accounts / Create Account

  query = <<-KQL
    Syslog
    | where Facility == "local6"
    | where SyslogMessage has_any ("CREATE USER", "GRANT ", "ALTER USER", "DROP USER")
    | extend DBUser = extract(@"db-vm,(\w+),", 1, SyslogMessage)
    | project TimeGenerated, Computer, DBUser, SyslogMessage
  KQL

  entity_mapping {
    entity_type = "Host"
    field_mapping {
      identifier  = "HostName"
      column_name = "Computer"
    }
  }
  entity_mapping {
    entity_type = "Account"
    field_mapping {
      identifier  = "Name"
      column_name = "DBUser"
    }
  }

  incident {
    create_incident_enabled = true
    grouping {
      enabled                 = false
      lookback_duration       = "PT5M"
      reopen_closed_incidents = false
      entity_matching_method  = "AllEntities"
    }
  }
}
