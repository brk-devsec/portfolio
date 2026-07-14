# =========================================================
#  Outputs
# =========================================================
output "bastion_public_ip" {
  description = "Bastion 공용 IP"
  value       = azurerm_public_ip.bastion.ip_address
}

output "web_public_ip" {
  description = "Web 공용 IP (WordPress: http://<ip>)"
  value       = azurerm_public_ip.web.ip_address
}

output "kali_public_ip" {
  description = "Kali 공용 IP"
  value       = azurerm_public_ip.kali.ip_address
}

output "db_private_ip" {
  description = "DB VM 사설 IP"
  value       = azurerm_network_interface.db.private_ip_address
}

output "web_private_ip" {
  description = "Web VM 사설 IP"
  value       = azurerm_network_interface.web.private_ip_address
}

output "log_analytics_workspace" {
  description = "Log Analytics Workspace 이름"
  value       = azurerm_log_analytics_workspace.main.name
}
