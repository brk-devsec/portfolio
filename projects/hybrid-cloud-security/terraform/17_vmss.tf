# ── Central VMSS (풀 가동) ──
resource "azurerm_linux_virtual_machine_scale_set" "central_vmss" {
  name                = "team601-central-vmss"
  resource_group_name = var.rgname_central
  location            = var.loca
  sku                 = var.vm_size
  instances           = 2
  admin_username      = var.admin_username
  zones               = ["1", "2"]
  zone_balance        = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  custom_data = base64encode(templatefile("${path.module}/install.sh.tpl", {
    site_ip      = azurerm_public_ip.central_appgw_ip.ip_address
    storage_acct = azurerm_storage_account.storage.name
    storage_key  = azurerm_storage_account.storage.primary_access_key
    share_name   = azurerm_storage_share.wp_media.name
    redis_host   = azurerm_managed_redis.central_redis.hostname
    redis_key    = azurerm_managed_redis.central_redis.default_database[0].primary_access_key
  }))

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.3.20231113"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ip-config"
      primary   = true
      subnet_id = azurerm_subnet.central_spoke_web.id
      application_gateway_backend_address_pool_ids = [
        tolist(azurerm_application_gateway.central_appgw.backend_address_pool)[0].id
      ]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
  depends_on = [
    azurerm_resource_group.rg_central,
    azurerm_firewall.central_firewall,
    azurerm_firewall_policy_rule_collection_group.central_fw_rules,
    azurerm_subnet_route_table_association.central_web_rt_assoc,
    azurerm_virtual_network_gateway_connection.central_vpn_conn
  ]
}

# ── Japan VMSS (DR 대기) ──
resource "azurerm_linux_virtual_machine_scale_set" "japan_vmss" {
  name = "team601-japan-vmss"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  sku                 = var.vm_size
  instances           = 1
  admin_username      = var.admin_username
  zones               = ["1", "2"]
  zone_balance        = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  custom_data = base64encode(templatefile("${path.module}/install.sh.tpl", {
    site_ip      = azurerm_public_ip.japan_appgw_ip.ip_address
    storage_acct = azurerm_storage_account.japan_storage.name
    storage_key  = azurerm_storage_account.japan_storage.primary_access_key
    share_name   = azurerm_storage_share.japan_wp_media.name
    redis_host   = azurerm_managed_redis.japan_redis.hostname
    redis_key    = azurerm_managed_redis.japan_redis.default_database[0].primary_access_key
  }))

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "9.3.20231113"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "vmss-nic"
    primary = true

    ip_configuration {
      name      = "vmss-ip-config"
      primary   = true
      subnet_id = azurerm_subnet.japan_spoke_web.id
      application_gateway_backend_address_pool_ids = [
        tolist(azurerm_application_gateway.japan_appgw.backend_address_pool)[0].id
      ]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }
  depends_on = [
    azurerm_resource_group.rg_japan,
    azurerm_firewall.japan_firewall,
    azurerm_firewall_policy_rule_collection_group.japan_fw_rules,
    azurerm_subnet_route_table_association.japan_web_rt_assoc,
    azurerm_virtual_network_gateway_connection.japan_vpn_conn
  ]
}