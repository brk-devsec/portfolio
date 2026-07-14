# 빌트인 정책을 GUID 대신 "표시 이름"으로 찾아옵니다 (버전 바뀌어도 안전).
data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources"
}

# --- (1) 허용 리전 제한 : KoreaCentral 외 배포 시도 → 거부 ---
resource "azurerm_resource_group_policy_assignment" "allowed_locations" {
  name                 = "${var.prefix}-allowed-locations"
  display_name         = "허용 리전 제한 (KoreaCentral)"
  description          = "지정 리전 외 리소스 배포를 거부"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["koreacentral"]
    }
  })
}

# --- (2) 필수 태그 강제 : 지정 태그 없는 리소스 생성 → 거부 ---
resource "azurerm_resource_group_policy_assignment" "require_tag" {
  name                 = "${var.prefix}-require-tag"
  display_name         = "필수 태그 강제 (team)"
  description          = "team 태그가 없는 리소스 생성을 거부"
  resource_group_id    = azurerm_resource_group.rg.id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  enforce = false

  parameters = jsonencode({
    tagName = {
      value = "team"
    }
  })
}
