# ── Central Local Network Gateway ──
resource "azurerm_local_network_gateway" "central_local_netgw" {
  name                = "team601-central-local-netgw"
  resource_group_name = var.rgname_central
  location            = var.loca

  # 온프레미스 Bluemax 방화벽 WAN IP
  gateway_address = "1.220.76.2"

  # 온프레미스 내부망 대역
  address_space = ["10.10.34.0/24"]
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan Local Network Gateway ──
resource "azurerm_local_network_gateway" "japan_local_netgw" {
  name = "team601-japan-local-netgw"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan

  gateway_address = "1.220.76.2"
  address_space   = ["10.10.34.0/24"]
  depends_on = [azurerm_resource_group.rg_japan]
}

