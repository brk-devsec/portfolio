resource "azurerm_resource_group" "rg_central" {
  name     = var.rgname_central
  location = var.loca
}

resource "azurerm_resource_group" "rg_japan" {
  name     = var.rgname_japan
  location = var.loca_japan
}


