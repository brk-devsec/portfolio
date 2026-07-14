# =========================================
#  메인 VNet + 서브넷 (for_each, 하드코딩 제거)
# =========================================
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "main" {
  for_each             = var.subnets
  name                 = "${var.prefix}-${each.key}-subnet"
  virtual_network_name = azurerm_virtual_network.main.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [each.value]
}

# =========================================
#  Kali 전용 VNet (외부 공격자, peering 없음)
# =========================================
resource "azurerm_virtual_network" "kali" {
  name                = "${var.prefix}-kali-vnet"
  address_space       = [var.kali_vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_subnet" "kali" {
  name                 = "${var.prefix}-kali-subnet"
  virtual_network_name = azurerm_virtual_network.kali.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = [var.kali_subnet_cidr]
}
