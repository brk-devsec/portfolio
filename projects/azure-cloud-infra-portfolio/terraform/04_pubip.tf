# ── Central 공인 IP ──
resource "azurerm_public_ip" "central_appgw_ip" {
  name                = "team601-central-appgw-ip"
  resource_group_name = var.rgname_central
  location            = var.loca
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_public_ip" "central_bastion_ip" {
  name                = "team601-central-bastion-ip"
  resource_group_name = var.rgname_central
  location            = var.loca
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_public_ip" "central_firewall_ip" {
  name                = "team601-central-firewall-ip"
  resource_group_name = var.rgname_central
  location            = var.loca
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_public_ip" "central_vpngw_ip" {
  name                = "team601-central-vpngw-ip"
  resource_group_name = var.rgname_central
  location            = var.loca
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1", "2", "3"]
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan 공인 IP ──
resource "azurerm_public_ip" "japan_appgw_ip" {
  name = "team601-japan-appgw-ip"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_public_ip" "japan_bastion_ip" {
  name = "team601-japan-bastion-ip"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_public_ip" "japan_firewall_ip" {
  name = "team601-japan-firewall-ip"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  allocation_method   = "Static"
  sku                 = "Standard"
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_public_ip" "japan_vpngw_ip" {
  name = "team601-japan-vpngw-ip"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  allocation_method   = "Static"
  sku                 = "Standard"
  zones = ["1", "2", "3"]
  depends_on = [azurerm_resource_group.rg_japan]
}

output "central_appgw_public_ip" {
  value = azurerm_public_ip.central_appgw_ip.ip_address
}

output "japan_appgw_public_ip" {
  value = azurerm_public_ip.japan_appgw_ip.ip_address
}

output "central_vpngw_public_ip" {
  value = azurerm_public_ip.central_vpngw_ip.ip_address
}

output "japan_vpngw_public_ip" {
  value = azurerm_public_ip.japan_vpngw_ip.ip_address
}