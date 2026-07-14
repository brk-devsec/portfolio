resource "azurerm_storage_account" "storage" {
  name                          = "team601storage2"
  resource_group_name           = var.rgname_central
  location                      = var.loca
  account_tier                  = "Standard"
  account_replication_type      = "GRS"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_storage_share" "wp_media" {
  name                 = "wp-media"
  storage_account_id   = azurerm_storage_account.storage.id
  quota                = 100
  depends_on           = [azurerm_storage_account.storage]
}

resource "azurerm_private_dns_zone" "storage_dns" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = var.rgname_central
  depends_on          = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_central_hub" {
  name                  = "storage-dns-central-hub-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.central_hub_vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_central_spoke" {
  name                  = "storage-dns-central-spoke-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.central_spoke_vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_resource_group.rg_central]
}


resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_japan_hub" {
  name                  = "storage-dns-japan-hub-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.japan_hub_vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_dns_japan_spoke" {
  name                  = "storage-dns-japan-spoke-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.storage_dns.name
  virtual_network_id    = azurerm_virtual_network.japan_spoke_vnet.id
  registration_enabled  = false
  depends_on            = [azurerm_resource_group.rg_central]
}

# ── Central File Private Endpoint ──
resource "azurerm_private_endpoint" "central_storage_pe" {
  name                = "team601-central-storage-pe"
  resource_group_name = var.rgname_central
  location            = var.loca
  subnet_id           = azurerm_subnet.central_spoke_pe.id

  private_service_connection {
    name                           = "storage-pe-conn"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }
  depends_on = [
    azurerm_storage_account.storage,
    azurerm_private_dns_zone_virtual_network_link.storage_dns_central_hub,
    azurerm_private_dns_zone_virtual_network_link.storage_dns_central_spoke
  ]
}

# ── Japan File Private Endpoint ──
resource "azurerm_private_endpoint" "japan_storage_pe" {
  name                = "team601-japan-storage-pe"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  subnet_id           = azurerm_subnet.japan_spoke_pe.id

  private_service_connection {
    name                           = "japan-storage-pe-conn"
    private_connection_resource_id = azurerm_storage_account.japan_storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "storage-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.storage_dns.id]
  }
  depends_on = [
    azurerm_storage_account.japan_storage,
    azurerm_private_dns_zone_virtual_network_link.storage_dns_japan_hub,
    azurerm_private_dns_zone_virtual_network_link.storage_dns_japan_spoke
  ]
}

resource "azurerm_storage_account" "japan_storage" {
  name                          = "team601storage2jp"
  resource_group_name           = var.rgname_japan
  location                      = var.loca_japan
  account_tier                  = "Standard"
  account_replication_type      = "LRS"    
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_storage_share" "japan_wp_media" {
  name               = "wp-media"
  storage_account_id = azurerm_storage_account.japan_storage.id
  quota              = 100
  depends_on         = [azurerm_storage_account.japan_storage]
}



# install.sh 에서 마운트에 사용할 정보 출력
output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}
output "storage_share_name" {
  value = azurerm_storage_share.wp_media.name
}

