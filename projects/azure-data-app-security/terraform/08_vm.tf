# =========================================================
#  VM 정의 (Bastion / Web / DB / Kali)
#  SSH 공개키: 코드 폴더 내 id_rsa.pub 직접 참조
# =========================================================

# --- Bastion ---
resource "azurerm_linux_virtual_machine" "bastion" {
  name                  = "${var.prefix}-bastion-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.bastion.id]
  tags                  = var.tags

  # 11_managed_identity.tf에서 Key Vault 접근 권한 부여 시 필요
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    # 12_disk_encryption.tf에서 생성한 DES로 OS 디스크 암호화
    disk_encryption_set_id = azurerm_disk_encryption_set.a_des.id
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "latest"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/bastion_init.sh.tpl", {
    admin_username = var.admin_username
    private_key    = file("id_rsa")
  }))

  depends_on = [
    azurerm_subnet_network_security_group_association.web
  ]
}

# --- DB (MariaDB) ---
resource "azurerm_linux_virtual_machine" "db" {
  name                  = "${var.prefix}-db-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.db.id]
  tags                  = var.tags

  # 11_managed_identity.tf에서 Key Vault 접근 권한 부여 시 필요
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    # 12_disk_encryption.tf에서 생성한 DES로 OS 디스크 암호화
    disk_encryption_set_id = azurerm_disk_encryption_set.a_des.id
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "latest"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/db_init.sh.tpl", {
    mysql_root_password = var.mysql_root_password
    mysql_app_user      = var.mysql_app_user
    mysql_app_password  = var.mysql_app_password
    mysql_database      = var.mysql_database
  }))

  depends_on = [
    azurerm_nat_gateway.nat,
    azurerm_subnet_nat_gateway_association.db,
    azurerm_subnet_network_security_group_association.db
  ]
}

# --- Web (Apache + WordPress) ---
resource "azurerm_linux_virtual_machine" "web" {
  name                  = "${var.prefix}-web-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.web.id]
  tags                  = var.tags

  # 11_managed_identity.tf에서 Key Vault 접근 권한 부여 시 필요
  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching                = "ReadWrite"
    storage_account_type   = "Standard_LRS"
    # 12_disk_encryption.tf에서 생성한 DES로 OS 디스크 암호화
    disk_encryption_set_id = azurerm_disk_encryption_set.a_des.id
  }

  source_image_reference {
    publisher = "resf"
    offer     = "rockylinux-x86_64"
    sku       = "9-lvm"
    version   = "latest"
  }

  plan {
    publisher = "resf"
    product   = "rockylinux-x86_64"
    name      = "9-lvm"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/web_init.sh.tpl", {
    db_host            = azurerm_network_interface.db.private_ip_address
    mysql_app_user     = var.mysql_app_user
    mysql_app_password = var.mysql_app_password
    mysql_database     = var.mysql_database
  }))

  depends_on = [
    azurerm_linux_virtual_machine.db,
    azurerm_subnet_network_security_group_association.bastion
  ]
}

# --- Kali (외부 공격자) ---
resource "azurerm_linux_virtual_machine" "kali" {
  name                  = "${var.prefix}-kali-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.kali.id]
  tags                  = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "kali-linux"
    offer     = "kali"
    sku       = "kali-2025-3"
    version   = "latest"
  }

  plan {
    publisher = "kali-linux"
    product   = "kali"
    name      = "kali-2025-3"
  }

  custom_data = base64encode(templatefile("${path.module}/scripts/kali_init.sh.tpl", {
    admin_username = var.admin_username
    web_public_ip  = azurerm_public_ip.web.ip_address
    db_private_ip  = azurerm_network_interface.db.private_ip_address
  }))

  depends_on = [
    azurerm_subnet_network_security_group_association.kali,
    azurerm_public_ip.web,
    azurerm_network_interface.db
  ]
}
