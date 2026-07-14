resource "azurerm_log_analytics_workspace" "law" {
  name                = "team601-law"
  resource_group_name = var.rgname_central
  location            = var.loca
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_log_analytics_workspace" "law_japan" {
  name                = "team601-japan-law"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  sku                 = "PerGB2018"
  retention_in_days   = 30
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_monitor_diagnostic_setting" "central_vmss_diag" {
  name                       = "team601-central-vmss-diag"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.central_vmss.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_monitor_diagnostic_setting" "central_appgw_diag" {
  name                       = "team601-central-appgw-diag"
  target_resource_id         = azurerm_application_gateway.central_appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_central]
}

resource "azurerm_monitor_diagnostic_setting" "central_firewall_diag" {
  name                       = "team601-central-firewall-diag"
  target_resource_id         = azurerm_firewall.central_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_central, azurerm_firewall.central_firewall]
}


resource "azurerm_monitor_diagnostic_setting" "japan_vmss_diag" {
  name                       = "team601-japan-vmss-diag"
  target_resource_id         = azurerm_linux_virtual_machine_scale_set.japan_vmss.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_japan.id

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_monitor_diagnostic_setting" "japan_appgw_diag" {
  name                       = "team601-japan-appgw-diag"
  target_resource_id         = azurerm_application_gateway.japan_appgw.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_japan.id

  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_japan]
}

resource "azurerm_monitor_diagnostic_setting" "japan_firewall_diag" {
  name                       = "team601-japan-firewall-diag"
  target_resource_id         = azurerm_firewall.japan_firewall.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law_japan.id

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_metric {
    category = "AllMetrics"
  }
  depends_on = [azurerm_resource_group.rg_japan, azurerm_firewall.japan_firewall]
}