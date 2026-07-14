# ── Central AppGW ──
resource "azurerm_application_gateway" "central_appgw" {
  name                = "team601-central-appgw"
  resource_group_name = var.rgname_central
  location            = var.loca
  firewall_policy_id  = azurerm_web_application_firewall_policy.central_waf_policy.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.central_hub_appgw.id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.central_appgw_ip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name = "web-backend-pool"
  }

  backend_http_settings {
    name                  = "web-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "web-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "web-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "web-listener"
    backend_address_pool_name  = "web-backend-pool"
    backend_http_settings_name = "web-http-settings"
    priority                   = 100
  }

  depends_on = [
    azurerm_subnet.central_hub_appgw,
    azurerm_public_ip.central_appgw_ip,
    azurerm_web_application_firewall_policy.central_waf_policy
  ]
}

# Central WAF Policy (Prevention 모드 - 4단계)
resource "azurerm_web_application_firewall_policy" "central_waf_policy" {
  name                = "team601-central-waf-policy"
  resource_group_name = var.rgname_central
  location            = var.loca

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  depends_on = [azurerm_resource_group.rg_central]
}

# ── South AppGW ──
resource "azurerm_application_gateway" "japan_appgw" {
  name = "team601-japan-appgw"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan
  firewall_policy_id  = azurerm_web_application_firewall_policy.japan_waf_policy.id

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.japan_hub_appgw.id
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.japan_appgw_ip.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  backend_address_pool {
    name = "web-backend-pool"
  }

  backend_http_settings {
    name                  = "web-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "web-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "web-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "web-listener"
    backend_address_pool_name  = "web-backend-pool"
    backend_http_settings_name = "web-http-settings"
    priority                   = 100
  }

  depends_on = [
    azurerm_subnet.japan_hub_appgw,
    azurerm_public_ip.japan_appgw_ip,
    azurerm_web_application_firewall_policy.japan_waf_policy
  ]
}

resource "azurerm_web_application_firewall_policy" "japan_waf_policy" {
  name = "team601-japan-waf-policy"
  resource_group_name = var.rgname_japan
  location            = var.loca_japan

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    max_request_body_size_in_kb = 128
    file_upload_limit_in_mb     = 100
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  depends_on = [azurerm_resource_group.rg_japan]
}
