# =========================================================
#  19_storage_security.tf — 묶음 A 추가 과업 (A-4): 스토리지 보안
#
#  목적: 스토리지 계정을 처음부터 보안 설정(After 상태)으로 생성.
#        Before(공개 접근 허용/HTTP 허용/SAS 무제한)는 실제 배포하지
#        않고, 아래 "캡처 절차"대로 일시적 설정 변경 후 시연.
#
#  적용 항목:
#    - 공개 접근 차단(private): allow_nested_items_to_be_public = false
#                                network_rules default_action    = "Deny"
#    - HTTPS 강제               : https_traffic_only_enabled     = true
#                                min_tls_version                 = "TLS1_2"
#    - SAS 만료·권한 제한       : sas_policy 블록 (최대 유효기간 1일)
#    - 저장 암호화               : Storage 계정은 기본적으로 SSE(저장 시 암호화)
#                                자동 적용됨 (별도 설정 불필요, 아래 주석 참고)
# =========================================================

# Storage 계정 이름은 전 세계 유니크 필요 + 소문자/숫자만 허용
resource "random_string" "a_storage" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_storage_account" "a_storage" {
  name                = "${var.prefix}stor${random_string.a_storage.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  # --- HTTPS 강제 ---
  https_traffic_only_enabled = true
  min_tls_version             = "TLS1_2"

  # --- 공개 접근 차단 (Before: 공개 컨테이너/Blob 익명 읽기 허용 → After: 전면 차단) ---
  allow_nested_items_to_be_public = false

  network_rules {
    default_action = "Deny"
    bypass          = ["AzureServices"]
  }

  # --- SAS 토큰 만료 제한 (Before: 무제한 SAS → After: 최대 1일) ---
  sas_policy {
    expiration_period = "01.00:00:00" # DD.HH:MM:SS 형식, 1일
    expiration_action = "Log"
  }

  # 저장 암호화(Encryption at Rest)는 Storage 계정 생성 시 Microsoft 관리 키(MMK)로
  # 자동 적용됩니다. Key Vault 연동 CMK로 바꾸려면 10_keyvault.tf의 a_main을
  # 재사용해 azurerm_storage_account_customer_managed_key 리소스를 추가하면 되지만,
  # 이번 과업 범위(A-4)에서는 기본 SSE 확인만으로 충분합니다.

  tags = var.tags
}

# 테스트/시연용 컨테이너 (Before/After 캡처에 사용)
resource "azurerm_storage_container" "a_test" {
  name                  = "test-container"
  storage_account_id    = azurerm_storage_account.a_storage.id
  container_access_type = "private" # After 상태 — Before 시연 시 일시적으로 "blob"으로 변경
}

# =========================================================
#  [캡처 절차 — Before/After 시연용, 수동 진행]
#
#  ★ Before 캡처 (공개 접근 허용 상태 시연):
#    1) 포털에서 team602-storXXXXXX → 구성(Configuration)
#       → "Blob 공용 액세스 허용" = 사용(Enabled)로 임시 변경
#    2) test-container → 액세스 수준 → "Blob(익명 Blob 읽기 전용)"으로 임시 변경
#    3) 아무 파일이나 업로드 후, 브라우저 시크릿 모드에서
#       https://<계정명>.blob.core.windows.net/test-container/<파일명>
#       접속 → 인증 없이 파일이 열리는 화면 캡처 (A-4 Before)
#
#  ★ After 캡처 (차단 확인):
#    4) 위에서 바꾼 설정을 원래대로(코드 상태: Deny/private)로 되돌리고
#       terraform apply 재실행 (또는 포털에서 직접 원복)
#    5) 동일 URL 재접속 → "리소스를 찾을 수 없음"/403 에러 화면 캡처 (A-4 After)
#
#  ★ SAS 정책 확인 캡처:
#    6) 포털 → 스토리지 계정 → 구성 → "허용되는 SAS 만료 기간"에
#       1일로 설정된 값이 표시된 화면 캡처
# =========================================================
