# =========================================
#  NAT Gateway : DB 서브넷 아웃바운드
#  (Web 은 공용 IP 보유, DB 는 Private 이라 NAT 필요)
# =========================================
resource "azurerm_nat_gateway" "nat" {
  name                = "${var.prefix}-nat"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "Standard"
  tags                = var.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat" {
  nat_gateway_id       = azurerm_nat_gateway.nat.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

resource "azurerm_subnet_nat_gateway_association" "db" {
  subnet_id      = azurerm_subnet.main["db"].id
  nat_gateway_id = azurerm_nat_gateway.nat.id

  depends_on = [azurerm_nat_gateway_public_ip_association.nat]
}
