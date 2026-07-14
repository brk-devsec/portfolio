# =========================================================
#  19_soar_playbook.tf
#  SOAR : Sentinel 인시던트 → 공격 IP 추출 → NSG 자동 차단
#
#  구성:
#    1. API 커넥션 2개 (azuresentinel, arm)
#    2. Logic App 워크플로우 (인시던트 트리거 → IP 추출 → For each → NSG 규칙 생성)
#
#  [중요] API 커넥션은 OAuth 인증이 필요하다.
#         apply 후 포털에서 각 커넥션을 1회 인증해야 실제로 동작한다.
#         (Terraform으로 인증 토큰까지는 자동화 불가)
#
#         [포털 경로]
#         team602-rg 리소스 그룹
#          → 'azuresentinel' API 연결 클릭
#          → 좌측 메뉴 '설정 > 일반 > API 연결 편집'
#          → [권한 부여] 버튼 클릭 → 로그인 → [저장]
#         'arm' API 연결도 동일하게 반복
#
#  [의존] azurerm_log_analytics_workspace.main (Sentinel)
#         azurerm_network_security_group.web
# =========================================================

# ---------------------------------------------------------
# 현재 구독/테넌트 정보
# ---------------------------------------------------------

# ---------------------------------------------------------
# API 커넥션 : Microsoft Sentinel
# ---------------------------------------------------------
resource "azurerm_api_connection" "sentinel" {
  name                = "azuresentinel"
  resource_group_name = azurerm_resource_group.rg.name
  managed_api_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Web/locations/${lower(var.location)}/managedApis/azuresentinel"
  display_name        = "azuresentinel"

  # 인증(토큰)은 포털에서 수동 권한 부여 필요 → 변경 무시
  lifecycle {
    ignore_changes = [parameter_values]
  }
}

# ---------------------------------------------------------
# API 커넥션 : Azure Resource Manager
# ---------------------------------------------------------
resource "azurerm_api_connection" "arm" {
  name                = "arm"
  resource_group_name = azurerm_resource_group.rg.name
  managed_api_id      = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/providers/Microsoft.Web/locations/${lower(var.location)}/managedApis/arm"
  display_name        = "arm"

  lifecycle {
    ignore_changes = [parameter_values]
  }
}

# ---------------------------------------------------------
# Logic App 워크플로우
#   - 포털에서 만든 정의를 그대로 코드화
# ---------------------------------------------------------
resource "azurerm_logic_app_workflow" "soar" {
  name                = "team602-soar-playbook"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  # 워크플로우가 참조하는 커넥션 파라미터
  workflow_parameters = {
    "$connections" = jsonencode({
      type         = "Object"
      defaultValue = {}
    })
  }

  parameters = {
    "$connections" = jsonencode({
      azuresentinel = {
        id                   = azurerm_api_connection.sentinel.managed_api_id
        connectionId         = azurerm_api_connection.sentinel.id
        connectionName       = "azuresentinel"
        connectionProperties = {}
      }
      arm = {
        id                   = azurerm_api_connection.arm.managed_api_id
        connectionId         = azurerm_api_connection.arm.id
        connectionName       = "arm"
        connectionProperties = {}
      }
    })
  }

  depends_on = [
    azurerm_api_connection.sentinel,
    azurerm_api_connection.arm,
  ]
}

# ---------------------------------------------------------
# 트리거 : Sentinel 인시던트 생성
# ---------------------------------------------------------
resource "azurerm_logic_app_trigger_custom" "incident" {
  name         = "Microsoft_Sentinel_인시던트"
  logic_app_id = azurerm_logic_app_workflow.soar.id

  body = jsonencode({
    type = "ApiConnectionWebhook"
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['azuresentinel']['connectionId']"
        }
      }
      body = {
        callback_url = "@listCallbackUrl()"
      }
      path = "/incident-creation"
    }
  })
}

# ---------------------------------------------------------
# 액션 : IP 추출 → For each → NSG 규칙 생성
#   포털 정의를 그대로 custom action으로 코드화
# ---------------------------------------------------------
resource "azurerm_logic_app_action_custom" "get_ip_and_block" {
  name         = "엔터티_-_IP_가져오기"
  logic_app_id = azurerm_logic_app_workflow.soar.id

  body = jsonencode({
    runAfter = {}
    type     = "ApiConnection"
    inputs = {
      host = {
        connection = {
          name = "@parameters('$connections')['azuresentinel']['connectionId']"
        }
      }
      method = "post"
      body   = "@json(triggerBody())?['object']?['properties']?['relatedEntities']"
      path   = "/entities/ip"
    }
  })

  depends_on = [azurerm_logic_app_trigger_custom.incident]
}

resource "azurerm_logic_app_action_custom" "for_each_block" {
  name         = "For_each"
  logic_app_id = azurerm_logic_app_workflow.soar.id

  body = jsonencode({
    foreach = "@body('엔터티_-_IP_가져오기')?['IPs']"
    type    = "Foreach"
    runAfter = {
      "엔터티_-_IP_가져오기" = ["Succeeded"]
    }
    actions = {
      "리소스_만들기_또는_업데이트" = {
        type = "ApiConnection"
        inputs = {
          host = {
            connection = {
              name = "@parameters('$connections')['arm']['connectionId']"
            }
          }
          method = "put"
          body = {
            properties = {
              priority                 = 200
              direction                = "Inbound"
              access                   = "Deny"
              protocol                 = "*"
              sourcePortRange          = "*"
              destinationPortRange     = "*"
              sourceAddressPrefix      = "@{items('For_each')?['Address']}"
              destinationAddressPrefix = "*"
            }
          }
          path = "/subscriptions/@{encodeURIComponent('${data.azurerm_subscription.current.subscription_id}')}/resourcegroups/@{encodeURIComponent('${azurerm_resource_group.rg.name}')}/providers/@{encodeURIComponent('Microsoft.Network')}/@{encodeURIComponent('networkSecurityGroups/team602-web-nsg/securityRules/Block-Attacker')}"
          queries = {
            "x-ms-api-version" = "2023-11-01"
          }
        }
      }
    }
  })

  depends_on = [azurerm_logic_app_action_custom.get_ip_and_block]
}
