# Azure Route Table
resource "azurerm_route_table" "main" {
  name                = "main-rt"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  route {
    name           = "to-aws"
    address_prefix = "10.0.0.0/16"  # AWS VPC CIDR
    next_hop_type  = "VirtualNetworkGateway"
  }

  route {
    name           = "internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

# Associate Route Table with Subnet
resource "azurerm_subnet_route_table_association" "main" {
  subnet_id      = azurerm_subnet.main.id
  route_table_id = azurerm_route_table.main.id
}