# =========================================================
#  모니터링 : Log Analytics + Sentinel + 로그 수집
#  Phase 1 부터 로그를 남기는 것이 목적
# =========================================================
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.prefix}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "time_sleep" "wait_law" {
  depends_on      = [azurerm_log_analytics_workspace.main]
  create_duration = "60s"
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = azurerm_log_analytics_workspace.main.id
}

# --- AMA (Azure Monitor Agent) : Web / DB ---
resource "azurerm_virtual_machine_extension" "ama_web" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.web.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_virtual_machine_extension" "ama_db" {
  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.db.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

# --- DCR : Syslog 수집 (local6 = MariaDB audit 포함) ---
resource "azurerm_monitor_data_collection_rule" "syslog" {
  name                = "${var.prefix}-dcr-syslog"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.main.id
      name                  = "law-dest"
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["law-dest"]
  }

  data_sources {
    syslog {
      name           = "syslog-source"
      streams        = ["Microsoft-Syslog"]
      facility_names = ["auth", "authpriv", "cron", "daemon", "kern", "syslog", "user", "local5", "local6"]
      log_levels     = ["Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
    }
  }
  depends_on = [time_sleep.wait_law]
}

resource "azurerm_monitor_data_collection_rule_association" "web" {
  name                    = "${var.prefix}-dcra-web"
  target_resource_id      = azurerm_linux_virtual_machine.web.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog.id

  depends_on = [azurerm_virtual_machine_extension.ama_web]
}

resource "azurerm_monitor_data_collection_rule_association" "db" {
  name                    = "${var.prefix}-dcra-db"
  target_resource_id      = azurerm_linux_virtual_machine.db.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog.id

  depends_on = [azurerm_virtual_machine_extension.ama_db]
}

# =========================================================
#  ↓↓↓ 아래부터 B파트 추가분 (로그 파이프라인 재현용) ↓↓↓
#  목적: 포털에서 손으로 켠 것들을 코드로 이관하여
#        조원이 terraform apply 만 해도 동일 환경 재현
# =========================================================

# ── 현재 구독 정보 참조 ──────────────────────────────────
data "azurerm_subscription" "current" {}

# =========================================================
#  ① Azure Activity Log → Log Analytics
#     "누가 구독에서 무엇을 했는가" (리소스 생성/삭제/권한변경 등)
#     → AzureActivity 테이블에 쌓임
# =========================================================
resource "azurerm_monitor_diagnostic_setting" "activity_to_law" {
  name                       = "${var.prefix}-activity-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log { category = "Administrative" }
  enabled_log { category = "Security" }
  enabled_log { category = "ServiceHealth" }
  enabled_log { category = "Alert" }
  enabled_log { category = "Recommendation" }
  enabled_log { category = "Policy" }
  enabled_log { category = "Autoscale" }
  enabled_log { category = "ResourceHealth" }
}

# =========================================================
#  ② Defender for Cloud 보안 경고 → Sentinel
#     (Azure Security Center = Defender for Cloud 의 구 명칭)
#     Brute Force 등 Defender 경고가 SecurityAlert 테이블로 유입
#
#  전제: 13_defender.tf 의 Defender for Servers 플랜이 On(Standard)
#        Sentinel 온보딩(azurerm_sentinel_log_analytics_workspace_onboarding)이 선행
# =========================================================
resource "azurerm_sentinel_data_connector_azure_security_center" "defender_alerts" {
  name                       = "${var.prefix}-defender-connector"
  log_analytics_workspace_id = azurerm_sentinel_log_analytics_workspace_onboarding.main.workspace_id
  subscription_id            = data.azurerm_subscription.current.subscription_id
}
