# ── Central VPN Gateway ──
resource "azurerm_virtual_network_gateway" "central_vpngw" {
  name                = "team601-central-vpngw"
  resource_group_name = var.rgname_central
  location            = var.loca
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1AZ"
  active_active       = false

  ip_configuration {
    name                          = "vpngw-ip-config"
    public_ip_address_id          = azurerm_public_ip.central_vpngw_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.central_hub_gateway.id
  }
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan VPN Gateway ──
resource "azurerm_virtual_network_gateway" "japan_vpngw" {
  name = "team601-japan-vpngw"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = "VpnGw1AZ"
  active_active       = false

  ip_configuration {
    name                          = "vpngw-ip-config"
    public_ip_address_id          = azurerm_public_ip.japan_vpngw_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.japan_hub_gateway.id
  }
  depends_on = [azurerm_resource_group.rg_japan]
}

