# =========================================================
#  B파트 로그 → Log Analytics 연속 내보내기 (Continuous Export)
#  13_defender.tf 하단 또는 별도 파일로 추가
#
#  목적: Defender for Cloud 의 보안 경고·권장사항·보안점수를
#        team602B-law 로 자동 내보내기 (조원 apply 시 동일 재현)
#
#  ※ 이름은 반드시 "ExportToWorkspace" — 이 이름이어야
#     포털 "연속 내보내기" 화면에 설정이 표시됨
#  ※ 전제: Defender for Servers 플랜 On(Standard), LAW 존재
# =========================================================

# 현재 구독 참조 (다른 파일에 이미 있으면 이 줄 생략)

resource "azurerm_security_center_automation" "export_to_law" {
  name                = "ExportToWorkspace"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  enabled             = true

  # 내보낼 대상: Log Analytics workspace (team602B-law)
  action {
    type        = "loganalytics"
    resource_id = azurerm_log_analytics_workspace.main.id
  }

  # ── 보안 경고 (Alerts) — 낮음/중간/높음 ──────────────
  source {
    event_source = "Alerts"

    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
    }
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Medium"
        property_type  = "String"
      }
    }
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Low"
        property_type  = "String"
      }
    }
  }

  # ── 보안 권장사항 (Assessments) ──────────────────────
  source {
    event_source = "Assessments"
  }

  # ── 보안 점수 (SecureScores) ─────────────────────────
  source {
    event_source = "SecureScores"
  }

  # 적용 범위: 현재 구독
  scopes = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]

  # 연속 내보내기는 apply 마다 diff 가 생길 수 있어 안정화용
  lifecycle {
    ignore_changes = [tags]
  }
}

# =========================================================
#  참고 - 내보내진 로그가 쌓이는 테이블 (KQL 확인용)
#   SecurityAlert          : 보안 경고
#   SecurityRecommendation : 보안 권장사항
#   SecureScores / SecureScoreControls : 보안 점수
#
#  ※ 내보내기 설정 직후 즉시 뜨지 않음.
#     Defender 평가·export 주기상 30분~1시간 후부터 수집됨.
# =========================================================
