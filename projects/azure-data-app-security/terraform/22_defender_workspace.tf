# =========================================================
#  21_defender_workspace.tf — 묶음 B 추가: Defender 데이터 워크스페이스 연결
#
#  목적: Defender for Cloud의 보안 경고·권장사항이 Azure가 자동 생성하는
#        숨겨진 워크스페이스가 아니라, 우리가 관리하는
#        Log Analytics Workspace(team602-law)로 명시적으로 모이도록 지정.
#        이렇게 해야 D파트(Sentinel)에서 Defender 데이터를 같은 워크스페이스
#        기준으로 통합 조회·탐지할 수 있음.
#
#  조회 방법 (Log Analytics 포털 > Logs):
#    SecurityAlert
#    | order by TimeGenerated desc
#
#    SecurityRecommendation
#    | order by TimeGenerated desc
# =========================================================

resource "azurerm_security_center_workspace" "b_workspace" {
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.main.id
}
