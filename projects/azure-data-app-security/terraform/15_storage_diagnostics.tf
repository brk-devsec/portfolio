# =========================================================
#  20_storage_diagnostics.tf — 묶음 A 추가: 스토리지 접근 로그 수집
#
#  목적: 19_storage_security.tf(a_storage)의 Blob 읽기/쓰기/삭제 이벤트를
#        기존 Log Analytics Workspace(team602-law)로 전송.
#        Key Vault(18_kv_diagnostics.tf)와 동일한 패턴.
#
#  ★ 참고: Storage Account는 계정 리소스 자체가 아니라 하위 서비스
#    (blobServices/default)에 진단 설정을 붙여야 로그 카테고리가
#    노출됩니다 (Key Vault처럼 계정 리소스에 바로 붙일 수 없음).
#
#  조회 방법 (Log Analytics 포털 > Logs):
#    StorageBlobLogs
#    | where AccountName == "<storage 계정 이름>"
#    | project TimeGenerated, OperationName, StatusText, CallerIpAddress, RequesterObjectId
#    | order by TimeGenerated desc
# =========================================================

resource "azurerm_monitor_diagnostic_setting" "a_storage_blob_diag" {
  name                       = "${var.prefix}-storage-blob-diag"
  target_resource_id         = "${azurerm_storage_account.a_storage.id}/blobServices/default"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }
}
