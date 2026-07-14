# =========================================================
#  12_disk_encryption.tf — 묶음 A: VM OS 디스크 암호화
#
#  목적: Web·DB·Bastion VM의 OS 디스크를 고객 관리 키(CMK)로
#        암호화하여 물리 디스크 탈취 시에도 데이터 보호 (과업 ③)
#
#  방식: Disk Encryption Set (DES) + Key Vault Key
#        → 플랫폼 관리 키(PMK) 대비 키 회전·파기 권한을 고객이 보유
#
#  ★ 전제 조건 (10_keyvault.tf와 연계):
#    1. Key Vault에 purge_protection_enabled = true 필요
#       → 10_keyvault.tf에서 현재 false로 설정되어 있음.
#          통합 담당자는 apply 전에 true로 변경할 것.
#          (purge_protection 활성화 후 Key Vault 삭제 불가 — 의도적 제한)
#
#    2. Key Vault에 Disk Encryption Set의 접근을 허용해야 함
#       → 이 파일 하단의 role_assignment 리소스가 처리
#
#  ★ VM 디스크에 DES를 연결하려면 08_vm.tf의 os_disk 블록에
#       disk_encryption_set_id = azurerm_disk_encryption_set.a_des.id
#    를 추가해야 합니다. 기존 파일 수정 금지 원칙상,
#    통합 담당자에게 해당 라인 추가를 요청할 것.
#
#  ★ 이 파일을 apply하기 전에 00_provider.tf에
#    random provider가 선언되어 있는지 확인할 것.
# =========================================================

# DES 전용 Key Vault — 디스크 암호화는 별도 KV 권장
# (purge_protection 강제 활성화가 기존 KV에 영향을 주지 않도록 분리)
resource "random_string" "a_des_kv" {
  length  = 6
  special = false
  upper   = false
  keepers = {
    rebuild = "2"
  }
}
resource "azurerm_key_vault" "a_des_kv" {
  name                = "${var.prefix}-deskv-${random_string.a_des_kv.result}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # RBAC 권한 모델 사용
  rbac_authorization_enabled = false

  # 디스크 암호화 세트 요구사항: purge_protection 필수
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  tags = var.tags

  access_policy {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get", "List", "Create", "Delete", "Update", "Purge",
    "WrapKey", "UnwrapKey", "GetRotationPolicy", "SetRotationPolicy"
  ]
}
lifecycle {
  ignore_changes = [access_policy]
}

  # data.azurerm_client_config는 10_keyvault.tf에서 이미 선언됨
  # 같은 Terraform 루트 모듈 내에서 공유되므로 재선언 불필요
}

# -------------------------------------------------------
#  Terraform 실행 주체에게 DES 전용 KV Key 관리 권한 부여
#  구독 레벨 문제로 주석처리하고 azure 포탈에서 생성 예정
# -------------------------------------------------------
/* resource "azurerm_role_assignment" "a_des_kv_admin" {
  scope                = azurerm_key_vault.a_des_kv.id
  role_definition_name = "Key Vault Crypto Officer"
  principal_id         = data.azurerm_client_config.current.object_id
} */

# -------------------------------------------------------
#  디스크 암호화용 RSA 키
#  - key_type RSA-HSM은 Premium SKU 필요 → standard에서는 RSA 사용
# -------------------------------------------------------
resource "azurerm_key_vault_key" "a_des_key" {
  name         = "${var.prefix}-des-key"
  key_vault_id = azurerm_key_vault.a_des_kv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  tags = var.tags

#  depends_on = [azurerm_role_assignment.a_des_kv_admin]  구독 레벨 문제로 주석처리하고 azure 포탈에서 생성 예정
}

# -------------------------------------------------------
#  Disk Encryption Set
#  - encryption_type: EncryptionAtRestWithCustomerKey (CMK 단독)
#    또는 EncryptionAtRestWithPlatformAndCustomerKeys (이중 암호화)
# -------------------------------------------------------
resource "azurerm_disk_encryption_set" "a_des" {
  name                = "${var.prefix}-des"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  key_vault_key_id = azurerm_key_vault_key.a_des_key.id

  # 고객 관리 키(CMK) 단독 암호화
  encryption_type = "EncryptionAtRestWithCustomerKey"

  # DES 자체의 Managed Identity (Key Vault 접근에 사용)
  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  depends_on = [
    azurerm_subnet_network_security_group_association.web,
#    azurerm_disk_encryption_set.a_des
  ]   
}
resource "null_resource" "a_des_policy" {
  depends_on = [azurerm_disk_encryption_set.a_des,
                azurerm_monitor_data_collection_rule.syslog]

  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command = <<EOT
      $des_msi = az disk-encryption-set show --name ${azurerm_disk_encryption_set.a_des.name} --resource-group ${azurerm_resource_group.rg.name} --query "identity.principalId" -o tsv
      az keyvault set-policy --name ${azurerm_key_vault.a_des_kv.name} --resource-group ${azurerm_resource_group.rg.name} --object-id "$des_msi" --key-permissions get wrapKey unwrapKey
    EOT
  }
}

# -------------------------------------------------------
#  DES의 System-assigned Identity → DES 전용 KV: 키 사용 권한 부여
#  DES가 Key Vault 키를 사용해 디스크를 암호화하기 위해 필요
#  구독 레벨 문제로 주석처리하고 azure 포탈에서 생성 예정
# -------------------------------------------------------
/* resource "azurerm_role_assignment" "a_des_kv_crypto_user" {
  scope                = azurerm_key_vault.a_des_kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.a_des.identity[0].principal_id

  depends_on = [azurerm_disk_encryption_set.a_des]
} */

# -------------------------------------------------------
#  [통합 담당자 조치 사항 — 08_vm.tf os_disk 블록에 추가 필요]
#
#  Web, DB, Bastion VM의 os_disk 블록에 아래 한 줄 추가:
#
#  os_disk {
#    caching                   = "ReadWrite"
#    storage_account_type      = "Standard_LRS"
#    disk_encryption_set_id    = azurerm_disk_encryption_set.a_des.id  ← 추가
#  }
#
#  ★ 기존 VM에 적용 시 VM이 재생성(destroy → create)될 수 있음.
#    terraform plan으로 변경 범위 확인 후 apply할 것.
# -------------------------------------------------------
