# Azure Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "main-vnet"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  address_space       = ["172.16.0.0/16"]
}

# Azure Subnet
resource "azurerm_subnet" "main" {
  name                 = "main-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.1.0/24"]
}

# Azure Gateway Subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.255.0/24"]
}