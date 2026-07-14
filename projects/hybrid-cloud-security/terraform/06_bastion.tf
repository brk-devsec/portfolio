# Central Bastion
resource "azurerm_bastion_host" "central_bastion" {
  name                = "team601-central-bastion"
  resource_group_name = var.rgname_central
  location            = var.loca
  sku                 = "Basic"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.central_spoke_bastion.id
    public_ip_address_id = azurerm_public_ip.central_bastion_ip.id
  }
  depends_on = [azurerm_resource_group.rg_central]
}

# Japan Bastion
resource "azurerm_bastion_host" "japan_bastion" {
  name = "team601-japan-bastion"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  sku                 = "Basic"

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = azurerm_subnet.japan_spoke_bastion.id
    public_ip_address_id = azurerm_public_ip.japan_bastion_ip.id
  }
  depends_on = [azurerm_resource_group.rg_japan]
}
