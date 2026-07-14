resource "azurerm_traffic_manager_profile" "tm" {
  name                   = "team601-tm"
  resource_group_name    = var.rgname_central
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "team601shop2"
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

  depends_on = [azurerm_resource_group.rg_central]
}

# ── Central 엔드포인트 (우선순위 1 = Active) ──
resource "azurerm_traffic_manager_external_endpoint" "central_ep" {
  name              = "central-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm.id
  target            = azurerm_public_ip.central_appgw_ip.ip_address
  priority          = 1
  endpoint_location = var.loca

  depends_on = [azurerm_application_gateway.central_appgw]
}

# ── Japan 엔드포인트 (우선순위 2 = Standby) ──
resource "azurerm_traffic_manager_external_endpoint" "japan_ep" {
  name              = "japan-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm.id
  target            = azurerm_public_ip.japan_appgw_ip.ip_address
  priority          = 2
  endpoint_location = var.loca_japan

  depends_on = [azurerm_application_gateway.japan_appgw]
}

# ── 사용자 접속 도메인 출력 ──
output "trafficmanager_fqdn" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}

