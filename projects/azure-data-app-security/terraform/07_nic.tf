# =========================================
#  네트워크 인터페이스 (NIC)
# =========================================

# Bastion (공용 IP)
resource "azurerm_network_interface" "bastion" {
  name                = "${var.prefix}-bastion-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.main["bastion"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion.id
  }

  depends_on = [
    azurerm_subnet.main,
    azurerm_public_ip.bastion
  ]
}

# Web (공용 IP 직접 - LB 없음)
resource "azurerm_network_interface" "web" {
  name                = "${var.prefix}-web-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.main["web"].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web.id
  }

  depends_on = [
    azurerm_subnet.main,
    azurerm_public_ip.web
  ]
}

# DB (Private)
resource "azurerm_network_interface" "db" {
  name                = "${var.prefix}-db-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.main["db"].id
    private_ip_address_allocation = "Dynamic"
  }

  depends_on = [azurerm_subnet.main]
}

# Kali (공용 IP, 외부 공격자)
resource "azurerm_network_interface" "kali" {
  name                = "${var.prefix}-kali-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.kali.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.kali.id
  }

  depends_on = [
    azurerm_subnet.kali,
    azurerm_public_ip.kali
  ]
}
