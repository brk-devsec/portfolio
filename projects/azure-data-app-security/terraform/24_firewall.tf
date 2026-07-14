# =========================================================
#  21_firewall.tf  —  Azure Firewall (아웃바운드/동서 트래픽 통제)
#
#  [독립 파일] 기존 코드(00~19) 수정 없음.
#  쓸 때만 폴더에 두고 apply. 안 쓰면 빼거나 .off 로 변경.
#
#  동작:
#   - 서브넷 아웃바운드를 UDR(라우팅 테이블)로 Firewall 경유시킴
#   - 데이터 유출(SCP/외부 전송), C2 통신 등 비인가 아웃바운드 차단
#
#  ★★ 중요 주의 ★★
#   1) 기존 06_nat.tf 의 NAT Gateway 가 db 서브넷 아웃바운드를 담당 중.
#      Firewall UDR 을 db 서브넷에 걸면 NAT 와 경로가 충돌한다.
#      → 아래는 web 서브넷에만 UDR 적용 (안전). db 까지 하려면 NAT 분리 결정 필요.
#   2) WAF(20) 적용 후에 Firewall 을 올려야 한다 (WAF 먼저, FW 나중).
#      FW UDR 을 먼저 걸면 AppGW/외부 통신이 꼬일 수 있다.
#   3) AzureFirewallSubnet 은 이름 고정 필수 (Azure 규칙).
# =========================================================

# ---------------------------------------------------------
# Firewall 전용 서브넷 (이름 고정, 빈 대역 10.0.7.0/26)
# ---------------------------------------------------------
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet" # 이름 변경 불가
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.7.0/26"]
}

# ---------------------------------------------------------
# Firewall 공인 IP
# ---------------------------------------------------------
resource "azurerm_public_ip" "firewall" {
  name                = "${var.prefix}-fw-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# ---------------------------------------------------------
# Azure Firewall
# ---------------------------------------------------------
resource "azurerm_firewall" "main" {
  name                = "${var.prefix}-fw"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.main.id
  tags                = var.tags

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = azurerm_subnet.firewall.id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

# ---------------------------------------------------------
# Firewall 정책 (네트워크/애플리케이션 규칙)
# ---------------------------------------------------------
resource "azurerm_firewall_policy" "main" {
  name                = "${var.prefix}-fw-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  tags                = var.tags
}

# 애플리케이션 규칙: 허용된 도메인만 아웃바운드 (예: 업데이트용)
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = "${var.prefix}-fw-rcg"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 100

  # 허용: OS 업데이트 등 정상 아웃바운드
  application_rule_collection {
    name     = "allow-essential"
    priority = 200
    action   = "Allow"

    rule {
      name = "allow-rocky-updates"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.0.3.0/24"] # web 서브넷
      destination_fqdns = ["*.rockylinux.org", "*.fedoraproject.org", "*.wordpress.org"]
    }

  }

  # 허용: Azure Monitor(AMA 로그 전송) — 서비스 태그, Deny(300)보다 먼저 평가
  network_rule_collection {
    name     = "allow-azure-monitor"
    priority = 250
    action   = "Allow"

    rule {
      name                  = "ama-servicetag"
      protocols             = ["TCP"]
      source_addresses      = ["10.0.3.0/24"]
      destination_addresses = ["AzureMonitor"]
      destination_ports     = ["443"]
    }
  }

  # 차단: 그 외 모든 아웃바운드 (데이터 유출/C2 차단)
  network_rule_collection {
    name     = "deny-exfiltration"
    priority = 300
    action   = "Deny"

    rule {
      name                  = "deny-all-outbound"
      protocols             = ["TCP", "UDP"]
      source_addresses      = ["10.0.3.0/24"] # web 서브넷
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }
}

# (Firewall 정책은 위 azurerm_firewall.main 의 firewall_policy_id 로 연결됨)

# ---------------------------------------------------------
# UDR (라우팅 테이블) : web 서브넷 아웃바운드 → Firewall
#   ★ db 서브넷은 NAT Gateway 와 충돌하므로 제외 (web 만 적용)
# ---------------------------------------------------------
resource "azurerm_route_table" "fw" {
  name                = "${var.prefix}-fw-rt"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  route {
    name                   = "to-firewall"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.main.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "web" {
  subnet_id      = azurerm_subnet.main["web"].id
  route_table_id = azurerm_route_table.fw.id

  depends_on = [azurerm_firewall.main]
}

# ---------------------------------------------------------
# Firewall 로그 → Log Analytics (Sentinel 탐지 연계)
# ---------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "${var.prefix}-fw-diag"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }
  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  metric {
    category = "AllMetrics"
  }
}

# ---------------------------------------------------------
# 출력
# ---------------------------------------------------------
output "firewall_public_ip" {
  description = "Azure Firewall 공인 IP"
  value       = azurerm_public_ip.firewall.ip_address
}

output "firewall_private_ip" {
  description = "Azure Firewall 사설 IP (UDR next hop)"
  value       = azurerm_firewall.main.ip_configuration[0].private_ip_address
}
