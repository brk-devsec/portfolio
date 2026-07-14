# ── Central VPN Connection ──
resource "azurerm_virtual_network_gateway_connection" "central_vpn_conn" {
  name                = "team601-central-vpn-conn"
  resource_group_name = var.rgname_central
  location            = var.loca

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.central_vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.central_local_netgw.id

  # 온프레미스 Bluemax와 동일한 PSK 설정
  shared_key = var.vpn_psk

  # 사용자 지정 IPsec/IKE 정책 (Bluemax와 동일하게 설정)
  ipsec_policy {
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    dh_group         = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
    sa_lifetime      = 27000
  }

  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan VPN Connection ──
resource "azurerm_virtual_network_gateway_connection" "japan_vpn_conn" {
  name                = "team601-japan-vpn-conn"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.japan_vpngw.id
  local_network_gateway_id   = azurerm_local_network_gateway.japan_local_netgw.id

  shared_key = var.vpn_psk

  # 사용자 지정 IPsec/IKE 정책 (Bluemax와 동일하게 설정)
  ipsec_policy {
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    dh_group         = "DHGroup14"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
    sa_lifetime      = 27000
  }

  depends_on = [azurerm_resource_group.rg_japan]
}

