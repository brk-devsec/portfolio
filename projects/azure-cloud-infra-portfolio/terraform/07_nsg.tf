# ── Central NSG ──
resource "azurerm_network_security_group" "central_web_nsg" {
  name                = "team601-central-web-nsg"
  resource_group_name = var.rgname_central
  location            = var.loca

  # AppGW → Web (HTTP)
  security_rule {
    name                       = "allow-http-from-appgw"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.1.0/24"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }

  # Bastion → Web (SSH)
  security_rule {
    name                       = "allow-ssh-from-bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.1.0.0/26"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  # AppGW 상태 프로브
  security_rule {
    name                       = "allow-appgw-probe"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
  }
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Central NSG ──
resource "azurerm_network_security_group" "central_pe_nsg" {
  name                = "team601-central-pe-nsg"
  resource_group_name = var.rgname_central
  location            = var.loca

  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
  depends_on = [azurerm_resource_group.rg_central]
}

# ── Japan NSG ──
resource "azurerm_network_security_group" "japan_web_nsg" {
  name = "team601-japan-web-nsg"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan

  security_rule {
    name                       = "allow-http-from-appgw"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.2.1.0/24"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }

  security_rule {
    name                       = "allow-ssh-from-bastion"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.3.0.0/26"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "22"
  }

  security_rule {
    name                       = "allow-appgw-probe"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
  }
  depends_on = [azurerm_resource_group.rg_japan]
}

# ── Japan NSG ──
resource "azurerm_network_security_group" "japan_pe_nsg" {
  name = "team601-japan-pe-nsg"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan

  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
  depends_on = [azurerm_resource_group.rg_japan]
}


