# ── Korea Central ──
resource "azurerm_virtual_network" "central_hub_vnet" {
  name                = "team601-central-hub-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.loca
  resource_group_name = var.rgname_central
  depends_on          = [azurerm_resource_group.rg_central]
}

resource "azurerm_virtual_network" "central_spoke_vnet" {
  name                = "team601-central-spoke-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.loca
  resource_group_name = var.rgname_central
  depends_on          = [azurerm_resource_group.rg_central]
}

# ── Japan East ──
resource "azurerm_virtual_network" "japan_hub_vnet" {
  name = "team601-japan-hub-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = var.loca_japan
  resource_group_name = var.rgname_japan
  depends_on          = [azurerm_resource_group.rg_japan]
}

resource "azurerm_virtual_network" "japan_spoke_vnet" {
  name = "team601-japan-spoke-vnet"
  address_space       = ["10.3.0.0/16"]
  location            = var.loca_japan
  resource_group_name = var.rgname_japan
  depends_on          = [azurerm_resource_group.rg_japan]
}
