# =========================================================
#  NSG : 서브넷별 분리 (계층 방어)
#    web-nsg     : HTTP/HTTPS(80/443) 외부 허용, SSH는 Bastion만
#    db-nsg      : MySQL(3306)은 Web 서브넷만, SSH는 Bastion만
#    bastion-nsg : SSH는 관리자 IP만
#    kali-nsg    : 공격자 - All-Allow (아웃바운드 공격용)
#  각 NSG는 명시 허용 외 모든 인바운드를 Deny (최소 노출)
# =========================================================

# =========================================================
#  web-nsg
# =========================================================
resource "azurerm_network_security_group" "web" {
  name                = "${var.prefix}-web-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-HTTP-HTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnets["bastion"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================================
#  db-nsg
# =========================================================
resource "azurerm_network_security_group" "db" {
  name                = "${var.prefix}-db-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-MySQL-From-Web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.subnets["web"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH-From-Bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.subnets["bastion"]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================================
#  bastion-nsg
# =========================================================
resource "azurerm_network_security_group" "bastion" {
  name                = "${var.prefix}-bastion-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-SSH-From-Admin"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Deny-All-Inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================================
#  kali-nsg (공격자 - All-Allow, 아웃바운드 공격용)
# =========================================================
resource "azurerm_network_security_group" "kali" {
  name                = "${var.prefix}-kali-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "Allow-All-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# =========================================================
#  서브넷 ↔ NSG 연결
# =========================================================
resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = azurerm_subnet.main["web"].id
  network_security_group_id = azurerm_network_security_group.web.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  subnet_id                 = azurerm_subnet.main["db"].id
  network_security_group_id = azurerm_network_security_group.db.id
}

resource "azurerm_subnet_network_security_group_association" "bastion" {
  subnet_id                 = azurerm_subnet.main["bastion"].id
  network_security_group_id = azurerm_network_security_group.bastion.id
}

resource "azurerm_subnet_network_security_group_association" "kali" {
  subnet_id                 = azurerm_subnet.kali.id
  network_security_group_id = azurerm_network_security_group.kali.id
}
