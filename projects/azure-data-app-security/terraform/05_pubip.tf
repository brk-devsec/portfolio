# =========================================
#  공용 IP (LB 없음 - Web VM 에 직접 부여)
# =========================================
resource "azurerm_public_ip" "bastion" {
  name                = "${var.prefix}-bastion-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "web" {
  name                = "${var.prefix}-web-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "kali" {
  name                = "${var.prefix}-kali-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_public_ip" "nat" {
  name                = "${var.prefix}-nat-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
