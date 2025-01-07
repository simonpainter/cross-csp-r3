# Azure Resource Group
resource "azurerm_resource_group" "main" {
  name     = "main-rg"
  location = "West US 2"
}

# Random PSKs for VPN tunnels
resource "random_password" "tunnel1_psk" {
  length  = 16
  special = false
}

resource "random_password" "tunnel2_psk" {
  length  = 16
  special = false
}