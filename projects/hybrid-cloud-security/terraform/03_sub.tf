# ── Central Hub 서브넷 ──
resource "azurerm_subnet" "central_hub_firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.central_hub_vnet.name
  resource_group_name  = var.rgname_central
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_subnet" "central_hub_appgw" {
  name                 = "AppGW-Subnet"
  virtual_network_name = azurerm_virtual_network.central_hub_vnet.name
  resource_group_name  = var.rgname_central
  address_prefixes     = ["10.0.1.0/24"]
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_subnet" "central_hub_gateway" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.central_hub_vnet.name
  resource_group_name  = var.rgname_central
  address_prefixes     = ["10.0.2.0/26"]
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Central Spoke 서브넷 ──
resource "azurerm_subnet" "central_spoke_bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.central_spoke_vnet.name
  resource_group_name  = var.rgname_central
  address_prefixes     = ["10.1.0.0/26"]
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_subnet" "central_spoke_web" {
  name                            = "Web-Subnet"
  virtual_network_name            = azurerm_virtual_network.central_spoke_vnet.name
  resource_group_name             = var.rgname_central
  address_prefixes                = ["10.1.1.0/24"]
  default_outbound_access_enabled = false
  depends_on = [azurerm_resource_group.rg_central]
}

# PE-Subnet (MySQL-Subnet 제거, 온프레미스 DB 사용)
resource "azurerm_subnet" "central_spoke_pe" {
  name                            = "PE-Subnet"
  virtual_network_name            = azurerm_virtual_network.central_spoke_vnet.name
  resource_group_name             = var.rgname_central
  address_prefixes                = ["10.1.2.0/24"]
  default_outbound_access_enabled = false
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan Hub 서브넷 ──
resource "azurerm_subnet" "japan_hub_firewall" {
  name                 = "AzureFirewallSubnet"
  virtual_network_name = azurerm_virtual_network.japan_hub_vnet.name
  resource_group_name  = var.rgname_japan
  address_prefixes     = ["10.2.0.0/24"]
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_subnet" "japan_hub_appgw" {
  name                 = "AppGW-Subnet"
  virtual_network_name = azurerm_virtual_network.japan_hub_vnet.name
  resource_group_name  = var.rgname_japan
  address_prefixes     = ["10.2.1.0/24"]
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_subnet" "japan_hub_gateway" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.japan_hub_vnet.name
  resource_group_name  = var.rgname_japan
  address_prefixes     = ["10.2.2.0/26"]
  depends_on = [azurerm_resource_group.rg_japan]
}

# ── Japan Spoke 서브넷 ──
resource "azurerm_subnet" "japan_spoke_bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.japan_spoke_vnet.name
  resource_group_name  = var.rgname_japan
  address_prefixes     = ["10.3.0.0/26"]
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_subnet" "japan_spoke_web" {
  name                            = "Web-Subnet"
  virtual_network_name            = azurerm_virtual_network.japan_spoke_vnet.name
  resource_group_name             = var.rgname_japan
  address_prefixes                = ["10.3.1.0/24"]
  default_outbound_access_enabled = false
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_subnet" "japan_spoke_pe" {
  name                            = "PE-Subnet"
  virtual_network_name            = azurerm_virtual_network.japan_spoke_vnet.name
  resource_group_name             = var.rgname_japan
  address_prefixes                = ["10.3.2.0/24"]
  default_outbound_access_enabled = false
  depends_on = [azurerm_resource_group.rg_japan]
}

