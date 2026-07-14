# ── Central Web UDR ──
resource "azurerm_route_table" "central_web_rt" {
  name                          = "team601-central-web-rt"
  resource_group_name           = var.rgname_central
  location                      = var.loca
  bgp_route_propagation_enabled = false

  route {
    name                   = "all-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.central_firewall.ip_configuration[0].private_ip_address
  }

  route {
    name           = "onprem-mysql"
    address_prefix = "10.10.34.0/24"
    next_hop_type  = "VirtualNetworkGateway"
  }

  depends_on = [azurerm_firewall.central_firewall]
}

# ── Japan Web UDR ──
resource "azurerm_route_table" "japan_web_rt" {
  name                          = "team601-japan-web-rt"
  resource_group_name           = var.rgname_japan
  location                      = var.loca_japan
  bgp_route_propagation_enabled = false

  route {
    name                   = "all-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.japan_firewall.ip_configuration[0].private_ip_address
  }

  route {
    name           = "onprem-mysql"
    address_prefix = "10.10.34.0/24"
    next_hop_type  = "VirtualNetworkGateway"
  }

  depends_on = [azurerm_firewall.japan_firewall]
}


# ── Central PE UDR ──
resource "azurerm_route_table" "central_pe_rt" {
  name                          = "team601-central-pe-rt"
  resource_group_name           = var.rgname_central
  location                      = var.loca
  bgp_route_propagation_enabled = false

  route {
    name                   = "all-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.central_firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_firewall.central_firewall]
}

# ── Japan PE UDR ──
resource "azurerm_route_table" "japan_pe_rt" {
  name                          = "team601-japan-pe-rt"
  resource_group_name           = var.rgname_japan
  location                      = var.loca_japan
  bgp_route_propagation_enabled = false

  route {
    name                   = "all-to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.japan_firewall.ip_configuration[0].private_ip_address
  }

  depends_on = [azurerm_firewall.japan_firewall]
}


# 서브넷 ↔ 라우트 테이블 연결
resource "azurerm_subnet_route_table_association" "central_web_rt_assoc" {
  subnet_id      = azurerm_subnet.central_spoke_web.id
  route_table_id = azurerm_route_table.central_web_rt.id
  depends_on = [
    azurerm_subnet.central_spoke_web,
    azurerm_route_table.central_web_rt
  ]
}

resource "azurerm_subnet_route_table_association" "central_pe_rt_assoc" {
  subnet_id      = azurerm_subnet.central_spoke_pe.id
  route_table_id = azurerm_route_table.central_pe_rt.id
  depends_on = [
    azurerm_subnet.central_spoke_pe,
    azurerm_route_table.central_pe_rt
  ]
}

resource "azurerm_subnet_route_table_association" "japan_web_rt_assoc" {
  subnet_id      = azurerm_subnet.japan_spoke_web.id
  route_table_id = azurerm_route_table.japan_web_rt.id
  depends_on = [
    azurerm_subnet.japan_spoke_web,
    azurerm_route_table.japan_web_rt
  ]
}

resource "azurerm_subnet_route_table_association" "japan_pe_rt_assoc" {
  subnet_id      = azurerm_subnet.japan_spoke_pe.id
  route_table_id = azurerm_route_table.japan_pe_rt.id
  depends_on = [
    azurerm_subnet.japan_spoke_pe,
    azurerm_route_table.japan_pe_rt
  ]
}
