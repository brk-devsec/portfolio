# Central NSG 연결
resource "azurerm_subnet_network_security_group_association" "central_web_nsg" {
  subnet_id                 = azurerm_subnet.central_spoke_web.id
  network_security_group_id = azurerm_network_security_group.central_web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "central_pe_nsg" {
  subnet_id                 = azurerm_subnet.central_spoke_pe.id
  network_security_group_id = azurerm_network_security_group.central_pe_nsg.id
}

# Japan NSG 연결
resource "azurerm_subnet_network_security_group_association" "japan_web_nsg" {
  subnet_id                 = azurerm_subnet.japan_spoke_web.id
  network_security_group_id = azurerm_network_security_group.japan_web_nsg.id
}

resource "azurerm_subnet_network_security_group_association" "japan_pe_nsg" {
  subnet_id                 = azurerm_subnet.japan_spoke_pe.id
  network_security_group_id = azurerm_network_security_group.japan_pe_nsg.id
}

