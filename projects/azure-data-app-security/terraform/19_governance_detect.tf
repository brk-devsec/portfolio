# =========================================================
#  과업 ① - 거버넌스 (권한 없이 적용 가능한 통제)
#  Contributor 권한으로는 RBAC/Policy 를 "강제"할 수 없으나,
#  거버넌스 관련 변경을 "탐지"하는 것은 가능하다.
#  → 역할/정책 할당 같은 권한 변경이 일어나면 알림을 발생시킨다.
#  (Microsoft.Insights/* 작업은 Contributor 에 포함됨 → apply 성공)
# =========================================================

# 알림 수신 그룹 (이메일)
variable "gov_alert_email" {
  description = "거버넌스 변경 알림을 받을 이메일 주소"
  type        = string
  default     = "bnmil8274@gmail.com"
}

resource "azurerm_monitor_action_group" "gov" {
  name                = "${var.prefix}-gov-ag"
  resource_group_name = azurerm_resource_group.rg.name
  short_name          = "govalert"

  email_receiver {
    name          = "admin"
    email_address = var.gov_alert_email
  }

  tags = var.tags
}

# 탐지 1) 역할 할당 생성/변경 → 권한 변경 감지
resource "azurerm_monitor_activity_log_alert" "role_change" {
  name                = "${var.prefix}-alert-role-assignment"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  scopes              = [azurerm_resource_group.rg.id]
  description         = "역할 할당(roleAssignments) 변경 시 알림 — 권한 변경 탐지"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/roleAssignments/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.gov.id
  }

  tags = var.tags
}

# 탐지 2) 정책 할당 생성/변경 → 거버넌스 정책 변경 감지
resource "azurerm_monitor_activity_log_alert" "policy_change" {
  name                = "${var.prefix}-alert-policy-assignment"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  scopes              = [azurerm_resource_group.rg.id]
  description         = "정책 할당(policyAssignments) 변경 시 알림 — 거버넌스 정책 변경 탐지"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Authorization/policyAssignments/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.gov.id
  }

  tags = var.tags
}

# 탐지 3) 네트워크 보안 그룹(NSG) 변경 → 방화벽 규칙 변경 감지
resource "azurerm_monitor_activity_log_alert" "nsg_change" {
  name                = "${var.prefix}-alert-nsg-change"
  resource_group_name = azurerm_resource_group.rg.name
  location            = "global"
  scopes              = [azurerm_resource_group.rg.id]
  description         = "NSG 규칙 변경 시 알림 — 네트워크 통제 변경 탐지"

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
  }

  action {
    action_group_id = azurerm_monitor_action_group.gov.id
  }

  tags = var.tags
}
