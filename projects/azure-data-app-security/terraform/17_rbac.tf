# ---------------------------------------------------------
#  역할 1) VM 운영 담당자 — 조회 + 시작/재시작만
#  서버 운영에 필요한 동작만 허용. 생성·삭제는 불가.
# ---------------------------------------------------------
resource "azurerm_role_definition" "vm_operator" {
  name        = "${var.prefix}-vm-operator"
  scope       = azurerm_resource_group.rg.id
  description = "VM 조회/시작/재시작만 가능한 최소 권한 역할 (생성·삭제 불가)"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/instanceView/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/restart/action",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.rg.id,
  ]
}

# ---------------------------------------------------------
#  역할 2) 모니터링 담당자 — 읽기 전용 (SOC / 감사)
#  로그·메트릭만 조회. 어떤 변경(쓰기·삭제·시작)도 불가.
# ---------------------------------------------------------
resource "azurerm_role_definition" "monitoring_reader" {
  name        = "${var.prefix}-monitoring-reader"
  scope       = azurerm_resource_group.rg.id
  description = "로그·메트릭 조회 전용 역할 (읽기 전용, 운영 변경 불가)"

  permissions {
    # 모든 리소스의 '읽기'만 허용 (*/read 는 쓰기·삭제를 포함하지 않음)
    actions = [
      "*/read",
      "Microsoft.Insights/alertRules/*/read",
      "Microsoft.OperationalInsights/workspaces/query/read",
    ]
    # Log Analytics 로그 데이터 조회(데이터 플레인)
    # data_actions = [
    #   "Microsoft.OperationalInsights/workspaces/query/*/read",
    # ]
    not_actions      = []
    # not_data_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.rg.id,
  ]
}

# ---------------------------------------------------------
#  역할 3) 네트워크 담당자 — 네트워크 리소스 전용
#  NSG·VNet·서브넷·공용 IP 등만 관리. VM(Compute)·DB(Sql)는 불가.
#  → Compute/Sql 은 허용 목록(actions)에 없으므로 자동으로 거부됨.
# ---------------------------------------------------------
resource "azurerm_role_definition" "network_operator" {
  name        = "${var.prefix}-network-operator"
  scope       = azurerm_resource_group.rg.id
  description = "네트워크 리소스만 관리하는 역할 (Compute·SQL 접근 불가)"

  permissions {
    actions = [
      "Microsoft.Network/*",
      "Microsoft.Resources/subscriptions/resourceGroups/read",
      "Microsoft.Resources/deployments/*",
    ]
    not_actions      = []
    data_actions     = []
    not_data_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.rg.id,
  ]
}

# =========================================================
#  역할 할당 (검증용 대상)
#  포털 > Microsoft Entra ID > 사용자 > 해당 계정 > "개체 ID(Object ID)" 복사
#  각 변수를 비워두면 역할 "정의"만 생성되고 "할당"은 건너뜁니다.
# =========================================================
variable "vm_operator_principal_id" {
  description = "VM 운영 역할을 부여할 대상의 Object ID"
  type        = string
  default     = ""
}

variable "monitoring_reader_principal_id" {
  description = "모니터링 읽기 전용 역할을 부여할 대상의 Object ID"
  type        = string
  default     = ""
}

variable "network_operator_principal_id" {
  description = "네트워크 담당 역할을 부여할 대상의 Object ID"
  type        = string
  default     = ""
}

resource "azurerm_role_assignment" "vm_operator" {
  count              = var.vm_operator_principal_id == "" ? 0 : 1
  scope              = azurerm_resource_group.rg.id
  role_definition_id = azurerm_role_definition.vm_operator.role_definition_resource_id
  principal_id       = var.vm_operator_principal_id
}

resource "azurerm_role_assignment" "monitoring_reader" {
  count              = var.monitoring_reader_principal_id == "" ? 0 : 1
  scope              = azurerm_resource_group.rg.id
  role_definition_id = azurerm_role_definition.monitoring_reader.role_definition_resource_id
  principal_id       = var.monitoring_reader_principal_id
}

resource "azurerm_role_assignment" "network_operator" {
  count              = var.network_operator_principal_id == "" ? 0 : 1
  scope              = azurerm_resource_group.rg.id
  role_definition_id = azurerm_role_definition.network_operator.role_definition_resource_id
  principal_id       = var.network_operator_principal_id
}
 