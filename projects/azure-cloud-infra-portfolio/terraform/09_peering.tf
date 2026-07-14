# ── Central Hub ↔ Spoke Peering ──
resource "azurerm_virtual_network_peering" "central_hub_to_spoke" {
  name                      = "central-hub-to-spoke"
  resource_group_name       = var.rgname_central
  virtual_network_name      = azurerm_virtual_network.central_hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.central_spoke_vnet.id
  allow_forwarded_traffic   = true
  # 4단계: VPN GW 배포 후 Gateway Transit 활성화
  allow_gateway_transit     = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "central_spoke_to_hub" {
  name                      = "central-spoke-to-hub"
  resource_group_name       = var.rgname_central
  virtual_network_name      = azurerm_virtual_network.central_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.central_hub_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  # 4단계: Hub VPN GW 빌려 쓰기
  use_remote_gateways       = true
  depends_on                = [azurerm_virtual_network_gateway.central_vpngw]
}

# ── Japan Hub ↔ Spoke Peering ──
resource "azurerm_virtual_network_peering" "japan_hub_to_spoke" {
  name                      = "japan-hub-to-spoke"
  resource_group_name       = var.rgname_japan
  virtual_network_name      = azurerm_virtual_network.japan_hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.japan_spoke_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways       = false
}

resource "azurerm_virtual_network_peering" "japan_spoke_to_hub" {
  name                      = "japan-spoke-to-hub"
  resource_group_name       = var.rgname_japan
  virtual_network_name      = azurerm_virtual_network.japan_spoke_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.japan_hub_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = true
  depends_on                = [azurerm_virtual_network_gateway.japan_vpngw]
}

