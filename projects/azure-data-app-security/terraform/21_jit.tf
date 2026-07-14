# ============================================================
# 14_jit.tf — JIT(Just-In-Time) VM 접근 제어
# 묶음 B / 리소스 라벨 접두사: b_
#
# 목적: SSH 포트(22)를 평소에는 차단하고, 관리자가 요청 시에만
#       최대 3시간 임시 개방. Phase 1(All-Allow) 대비 증거 확보.
#
# ★ azurerm ~> 4.0 에서 azurerm_security_center_jit_network_access_policy
#   리소스 타입이 provider에서 완전 제거됨 → Terraform 미지원.
#   JIT는 [방법 2] 포털 수동 설정으로 진행. 캡처로 증거 대체.
#
# 전제 조건: 13_defender.tf의 b_vm (Defender for Servers P1) 활성화 필요.
# ============================================================


# ── [방법 1] Terraform 미지원 (azurerm 4.x에서 제거됨) ────────
#
# 아래 리소스는 azurerm ~> 4.0에서 삭제된 타입이라 plan 단계에서 에러.
# 주석으로만 보존, 절대 주석 해제하지 말 것.
#
# /*
# resource "azurerm_security_center_jit_network_access_policy" "b_web_jit" {
#   ...  ← provider 4.x 미지원, 사용 불가
# }
# */


# ── [방법 2] 포털 수동 설정 (현재 진행 방식) ─────────────────
#
# ┌─ 설정 순서 ──────────────────────────────────────────────┐
# │ 1. Azure Portal → "Microsoft Defender for Cloud" 검색    │
# │ 2. 좌측 메뉴 [Workload protections]                       │
# │    → [Just-in-time VM access] 클릭                       │
# │ 3. [Not Configured] 탭에서 web·bastion VM 체크            │
# │    → [Enable JIT on X VMs] 클릭                          │
# │ 4. 포트 22 규칙 확인 (기본: 최대 3시간, 허용 IP: *)       │
# │ 5. 저장 후 [Configured] 탭 이동                          │
# │    → 설정 화면 캡처 (B-05)                               │
# └──────────────────────────────────────────────────────────┘
#
#
# ┌─ Before 캡처 (B-04) — JIT 설정 전에 먼저 ───────────────┐
# │ ssh -i id_rsa azureadmin@<web-public-ip>                  │
# │ → 접속 성공 화면 캡처                                     │
# │ → 파일명: B-04_ssh_before.png                            │
# └──────────────────────────────────────────────────────────┘
#
#
# ┌─ After 캡처 (B-06·B-07) — JIT 설정 후 ──────────────────┐
# │                                                           │
# │ [B-06] JIT 요청 없이 SSH 시도 → 차단 확인               │
# │   ssh -i id_rsa azureadmin@<web-public-ip>               │
# │   → Connection timed out 화면 캡처                       │
# │   → 파일명: B-06_ssh_jit차단_after.png                   │
# │                                                           │
# │ [JIT 접근 요청 — CLI]                                    │
# │   az security jit-policy initiate \                       │
# │     --name "default" \                                    │
# │     --resource-group "<rg-name>" \                        │
# │     --virtual-machines "[{                                │
# │       \"id\": \"<web-vm-resource-id>\",                   │
# │       \"ports\": [{                                       │
# │         \"number\": 22,                                   │
# │         \"duration\": \"PT3H\",                           │
# │         \"allowedSourceAddressPrefix\": \"<내_공인_IP>\"  │
# │       }]                                                  │
# │     }]"                                                   │
# │                                                           │
# │   또는 포털에서: Configured VM 선택 → [Request access]   │
# │                                                           │
# │ [B-07] JIT 요청 후 SSH 시도 → 접속 성공 확인            │
# │   ssh -i id_rsa azureadmin@<web-public-ip>               │
# │   → 접속 성공 화면 캡처                                   │
# │   → 파일명: B-07_ssh_jit허용_after.png                   │
# └──────────────────────────────────────────────────────────┘
