# =========================================================
#  22_app_registration.tf — 묶음 A 추가: 앱 등록 + Key Vault 접근
#
#  목적: Managed Identity(VM 전용)와 달리, Azure 밖 스크립트·CI/CD 등
#        외부 자동화가 Key Vault에 접근할 수 있는 신원(Service Principal)을
#        발급하고, 접근 시 18_kv_diagnostics.tf의 로그에 함께 기록되는지 확인.
#
#  ★ azuread provider 필요 — 00_provider.tf에 아래 블록 추가 필요
#    (기존 파일 수정 금지 원칙상 통합 시 별도 반영):
#
#    required_providers {
#      azuread = {
#        source  = "hashicorp/azuread"
#        version = "~> 3.0"
#      }
#    }
#    provider "azuread" {}
#
#  ★ 대상 Key Vault: a_main (10_keyvault.tf, 시크릿 저장용)
#    a_des_kv(디스크 암호화 키 전용)는 이 기능 범위 밖.
# =========================================================

# 현재 Entra ID 로그인 주체 정보 (앱 소유자 지정에 사용)
data "azuread_client_config" "current" {}

# -------------------------------------------------------
#  앱 등록 — Entra ID에 애플리케이션 신분증 생성
# -------------------------------------------------------
resource "azuread_application" "a_app" {
  display_name = "${var.prefix}-kv-reader-app"
  owners       = [data.azuread_client_config.current.object_id]
}

# -------------------------------------------------------
#  서비스 프린시펄 — 앱이 실제로 로그인·인증에 사용할 신원
#  (azuread_application은 "정의"이고, service_principal이 "실체")
# -------------------------------------------------------
resource "azuread_service_principal" "a_sp" {
  client_id = azuread_application.a_app.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# -------------------------------------------------------
#  앱 시크릿 — client_id와 함께 로그인에 사용할 비밀번호
#  유효기간 1년(8760시간), 만료 후 재발급 필요
# -------------------------------------------------------
resource "azuread_application_password" "a_app_secret" {
  application_id    = azuread_application.a_app.id
  display_name      = "${var.prefix}-kv-reader-secret"
  end_date_relative = "8760h"
}

# -------------------------------------------------------
#  기존 Key Vault(a_main)에 이 앱의 Secret 읽기 권한 부여
#  Access Policy 모델 통일 (11_managed_identity.tf와 동일 패턴)
# -------------------------------------------------------
resource "azurerm_key_vault_access_policy" "a_app_kv" {
  key_vault_id = azurerm_key_vault.a_main.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azuread_service_principal.a_sp.object_id

  secret_permissions = ["Get", "List"]
}

# -------------------------------------------------------
#  테스트용 출력값 — 앱 자격증명으로 로그인할 때 필요
#  client_secret은 민감정보라 sensitive 처리
# -------------------------------------------------------
output "a_app_client_id" {
  description = "앱 등록 client_id — 로그인 시 -u 값"
  value       = azuread_application.a_app.client_id
}

output "a_app_tenant_id" {
  description = "테넌트 ID — 로그인 시 -t 값"
  value       = data.azurerm_client_config.current.tenant_id
}

output "a_app_client_secret" {
  description = "앱 시크릿 — 로그인 시 -p 값 (민감정보)"
  value       = azuread_application_password.a_app_secret.value
  sensitive   = true
}

# =========================================================
#  [검증 절차 — 통합 담당자 안내]
#
#  1) apply 후 자격증명 확인:
#     terraform output a_app_client_id
#     terraform output a_app_tenant_id
#     terraform output -raw a_app_client_secret
#
#  2) 앱 자격증명으로 로그인 (사람 계정이 아닌 앱으로 전환):
#     az login --service-principal -u <client_id> -t <tenant_id> -p <client_secret>
#
#  3) Key Vault 시크릿 조회 시도 → 성공해야 정상
#     az keyvault secret show --vault-name team602-kv-d3hni8 --name db-root-password --query value -o tsv
#
#  4) 본인 계정으로 복귀 (중요 — 앱 계정으로 계속 있으면 이후 명령어 다 앱 권한으로 실행됨)
#     az logout
#     az login
#
#  5) 15~20분 후 Log Analytics에서 앱의 접근이 로그에 잡혔는지 확인:
#     AzureDiagnostics
#     | where ResourceType == "VAULTS"
#     | where Resource == "TEAM602-KV-D3HNI8"
#     | order by TimeGenerated desc
#     → identity_claim_appid_g 또는 유사 필드에 client_id(GUID)가 사람 계정 대신 찍혀있으면 확인 완료
# =========================================================
