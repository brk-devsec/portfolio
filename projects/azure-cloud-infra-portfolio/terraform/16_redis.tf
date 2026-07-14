# Redis Private DNS Zone
resource "azurerm_private_dns_zone" "redis_dns" {
  name                = "privatelink.redis.azure.net"
  resource_group_name = var.rgname_central
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_central_hub" {
  name                  = "redis-dns-central-hub-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.redis_dns.name
  virtual_network_id    = azurerm_virtual_network.central_hub_vnet.id
  registration_enabled  = false
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_central_spoke" {
  name                  = "redis-dns-central-spoke-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.redis_dns.name
  virtual_network_id    = azurerm_virtual_network.central_spoke_vnet.id
  registration_enabled  = false
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_japan_hub" {
  name                  = "redis-dns-japan-hub-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.redis_dns.name
  virtual_network_id    = azurerm_virtual_network.japan_hub_vnet.id
  registration_enabled  = false
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis_dns_japan_spoke" {
  name                  = "redis-dns-japan-spoke-link"
  resource_group_name   = var.rgname_central
  private_dns_zone_name = azurerm_private_dns_zone.redis_dns.name
  virtual_network_id    = azurerm_virtual_network.japan_spoke_vnet.id
  registration_enabled  = false
  depends_on = [azurerm_resource_group.rg_central]
}

# Azure Managed Redis (Central)
resource "azurerm_managed_redis" "central_redis" {
  name                = "team601-redis"
  resource_group_name = var.rgname_central
  location            = var.loca
  sku_name            = "Balanced_B1"

  default_database {
    eviction_policy = "AllKeysLRU"
    access_keys_authentication_enabled = true
    clustering_policy = "EnterpriseCluster"
  }

  public_network_access = "Disabled"

  depends_on = [azurerm_resource_group.rg_central]
}

# Redis Private Endpoint (Central PE-Subnet)
resource "azurerm_private_endpoint" "central_redis_pe" {
  name                = "team601-redis-pe"
  resource_group_name = var.rgname_central
  location            = var.loca
  subnet_id           = azurerm_subnet.central_spoke_pe.id

  private_service_connection {
    name                           = "redis-pe-conn"
    private_connection_resource_id = azurerm_managed_redis.central_redis.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_dns.id]
  }

  depends_on = [
    azurerm_managed_redis.central_redis,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_central_hub,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_central_spoke,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_japan_hub,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_japan_spoke
  ]
}

output "central_redis_hostname" {
  value     = azurerm_managed_redis.central_redis.hostname
  sensitive = true
}


# Japan Redis (페일오버 시 Japan 리전 로컬 캐시)
resource "azurerm_managed_redis" "japan_redis" {
  name                = "team601-japan-redis"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  sku_name            = "Balanced_B1"

  default_database {
    eviction_policy = "AllKeysLRU"
    access_keys_authentication_enabled = true
    clustering_policy = "EnterpriseCluster"
  }

  public_network_access = "Disabled"

  depends_on = [azurerm_resource_group.rg_japan]
}

# Japan Redis Private Endpoint (Japan PE-Subnet)
resource "azurerm_private_endpoint" "japan_redis_pe" {
  name                = "team601-japan-redis-pe"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  subnet_id           = azurerm_subnet.japan_spoke_pe.id

  private_service_connection {
    name                           = "japan-redis-pe-conn"
    private_connection_resource_id = azurerm_managed_redis.japan_redis.id
    subresource_names              = ["redisEnterprise"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "redis-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.redis_dns.id]
  }

  depends_on = [
    azurerm_managed_redis.japan_redis,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_japan_hub,
    azurerm_private_dns_zone_virtual_network_link.redis_dns_japan_spoke
  ]
}

output "japan_redis_hostname" {
  value     = azurerm_managed_redis.japan_redis.hostname
  sensitive = true
}