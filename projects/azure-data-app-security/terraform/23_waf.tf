# =========================================================
#  20_waf.tf  —  App Gateway + WAF (L7 웹 공격 차단)
#
#  [독립 파일] 기존 코드(00~19) 수정 없음.
#  쓸 때만 이 파일을 폴더에 두고 apply. 안 쓰면 빼거나 .off 로 변경.
#
#  동작:
#   - 외부 진입점을 App Gateway(WAF)로 일원화
#   - WAF_v2 SKU + OWASP CRS 룰셋으로 SQLi/XSS 등 차단
#   - 백엔드 = Web VM (사설 IP)
#
#  [선행/주의]
#   - Web VM의 공인 IP 직접 노출을 막으려면, 외부 접근을 AppGW IP로 안내.
#     (기존 web 공인 IP 리소스는 그대로 둬도 되지만, 시나리오상 AppGW가 진입점)
#   - 신규 서브넷 AppGatewaySubnet 을 이 파일 안에서 독립 생성 (기존 subnets 변수 안 건드림)
# =========================================================

# ---------------------------------------------------------
# AppGateway 전용 서브넷 (빈 대역 10.0.6.0/24)
# ---------------------------------------------------------
resource "azurerm_subnet" "appgw" {
  name                 = "AppGatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.6.0/24"]
}

# ---------------------------------------------------------
# AppGateway 공인 IP
# ---------------------------------------------------------
resource "azurerm_public_ip" "appgw" {
  name                = "${var.prefix}-appgw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# ---------------------------------------------------------
# WAF 정책 (OWASP CRS)
# ---------------------------------------------------------
resource "azurerm_web_application_firewall_policy" "main" {
  name                = "${var.prefix}-waf-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = "Prevention" # 탐지만 하려면 "Detection"
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
}

# ---------------------------------------------------------
# Application Gateway (WAF_v2)
# ---------------------------------------------------------
locals {
  appgw_name = "${var.prefix}-appgw"

  be_pool   = "web-backend-pool"
  be_http   = "web-http-settings"
  fe_port   = "frontend-port-80"
  fe_ip     = "frontend-ip"
  listener  = "http-listener"
  routerule = "http-routing-rule"
}

resource "azurerm_application_gateway" "main" {
  name                = local.appgw_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  # WAF 정책 연결
  firewall_policy_id = azurerm_web_application_firewall_policy.main.id

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = local.fe_port
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.fe_ip
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # 백엔드 = Web VM 사설 IP
  backend_address_pool {
    name         = local.be_pool
    ip_addresses = [azurerm_network_interface.web.private_ip_address]
  }

  backend_http_settings {
    name                  = local.be_http
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener
    frontend_ip_configuration_name = local.fe_ip
    frontend_port_name             = local.fe_port
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.routerule
    rule_type                  = "Basic"
    http_listener_name         = local.listener
    backend_address_pool_name  = local.be_pool
    backend_http_settings_name = local.be_http
    priority                   = 100
  }

  depends_on = [
    azurerm_subnet.appgw,
    azurerm_public_ip.appgw,
    azurerm_web_application_firewall_policy.main,
  ]
}

# ---------------------------------------------------------
# WAF 로그 → Log Analytics (Sentinel 탐지 연계)
#   기존 azurerm_log_analytics_workspace 참조명에 맞춰 사용.
#   (워크스페이스 리소스명이 다르면 아래 한 줄만 수정)
# ---------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "waf" {
  name                       = "${var.prefix}-waf-diag"
  target_resource_id         = azurerm_application_gateway.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "ApplicationGatewayFirewallLog"
  }
  enabled_log {
    category = "ApplicationGatewayAccessLog"
  }

  metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------
# 출력
# ---------------------------------------------------------
output "appgw_public_ip" {
  description = "App Gateway(WAF) 진입점 공인 IP"
  value       = azurerm_public_ip.appgw.ip_address
}
