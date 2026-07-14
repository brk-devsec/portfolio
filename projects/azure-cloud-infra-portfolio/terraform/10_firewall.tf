# ── Central Firewall ──
resource "azurerm_firewall" "central_firewall" {
  name                = "team601-central-firewall"
  resource_group_name = var.rgname_central
  location            = var.loca
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id = azurerm_firewall_policy.central_fw_policy.id

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.central_hub_firewall.id
    public_ip_address_id = azurerm_public_ip.central_firewall_ip.id
  }
  depends_on = [azurerm_resource_group.rg_central]
}


# Central Firewall 정책 - WordPress 트래픽 허용
resource "azurerm_firewall_policy" "central_fw_policy" {
  name                = "team601-central-fw-policy"
  resource_group_name = var.rgname_central
  location            = var.loca
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_firewall_policy_rule_collection_group" "central_fw_rules" {
  name               = "team601-central-fw-rules"
  firewall_policy_id = azurerm_firewall_policy.central_fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "allow-web-to-onprem-mysql"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "web-to-mysql"
      protocols             = ["TCP"]
      source_addresses      = ["10.1.1.0/24"]
      destination_addresses = ["10.10.34.119"]
      destination_ports     = ["3306"]
    }
  }

  network_rule_collection {
    name     = "allow-outbound"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "spoke-outbound-internet"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.1.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }
  }
  depends_on = [azurerm_resource_group.rg_central]
}

output "central_firewall_private_ip" {
  value = azurerm_firewall.central_firewall.ip_configuration[0].private_ip_address
}

# ── Japan Firewall ──
resource "azurerm_firewall" "japan_firewall" {
  name = "team601-japan-firewall"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id = azurerm_firewall_policy.japan_fw_policy.id

  ip_configuration {
    name                 = "firewall-ip-config"
    subnet_id            = azurerm_subnet.japan_hub_firewall.id
    public_ip_address_id = azurerm_public_ip.japan_firewall_ip.id
  }
  depends_on = [azurerm_resource_group.rg_japan]
}


# Japan Firewall 정책 - WordPress 트래픽 허용
resource "azurerm_firewall_policy" "japan_fw_policy" {
  name = "team601-japan-fw-policy"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_firewall_policy_rule_collection_group" "japan_fw_rules" {
  name = "team601-japan-fw-rules"
  firewall_policy_id = azurerm_firewall_policy.japan_fw_policy.id
  priority           = 100

  network_rule_collection {
    name     = "allow-web-to-onprem-mysql"
    priority = 100
    action   = "Allow"

    rule {
      name                  = "web-to-mysql"
      protocols             = ["TCP"]
      source_addresses      = ["10.3.1.0/24"]
      destination_addresses = ["10.10.34.119"]
      destination_ports     = ["3306"]
    }
  }

  network_rule_collection {
    name     = "allow-outbound"
    priority = 200
    action   = "Allow"

    rule {
      name                  = "spoke-outbound-internet"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.3.0.0/16"]
      destination_addresses = ["*"]
      destination_ports     = ["80", "443"]
    }
  }
  depends_on = [azurerm_resource_group.rg_japan]
}

output "japan_firewall_private_ip" {
  value = azurerm_firewall.japan_firewall.ip_configuration[0].private_ip_address
}

