# Azure Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway" {
  name                = "vpn-gateway-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                = "Standard"
}

# Azure VPN Gateway
resource "azurerm_virtual_network_gateway" "main" {
  name                = "main-vpn-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  active_active = false
  enable_bgp    = false

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# Azure Local Network Gateway for Tunnel 1
resource "azurerm_local_network_gateway" "aws_tunnel1" {
  name                = "aws-local-gateway-1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  gateway_address     = aws_vpn_connection.to_azure.tunnel1_address

  address_space = [
    "10.0.0.0/16"  # AWS VPC CIDR
  ]
}

# Azure Local Network Gateway for Tunnel 2
resource "azurerm_local_network_gateway" "aws_tunnel2" {
  name                = "aws-local-gateway-2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  gateway_address     = aws_vpn_connection.to_azure.tunnel2_address

  address_space = [
    "10.0.0.0/16"  # AWS VPC CIDR
  ]
}

# Azure VPN Connection for Tunnel 1
resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel1" {
  name                = "to-aws-1"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type                               = "IPsec"
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id           = azurerm_local_network_gateway.aws_tunnel1.id
  shared_key                         = random_password.tunnel1_psk.result
  connection_protocol                = "IKEv2"
  use_policy_based_traffic_selectors = false
  dpd_timeout_seconds                = 45

  ipsec_policy {
    dh_group         = "DHGroup2"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
    sa_lifetime      = 27000
  }
}

# Azure VPN Connection for Tunnel 2
resource "azurerm_virtual_network_gateway_connection" "to_aws_tunnel2" {
  name                = "to-aws-2"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type                               = "IPsec"
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id           = azurerm_local_network_gateway.aws_tunnel2.id
  shared_key                         = random_password.tunnel2_psk.result
  connection_protocol                = "IKEv2"
  use_policy_based_traffic_selectors = false
  dpd_timeout_seconds                = 45

  ipsec_policy {
    dh_group         = "DHGroup2"
    ike_encryption   = "AES256"
    ike_integrity    = "SHA256"
    ipsec_encryption = "AES256"
    ipsec_integrity  = "SHA256"
    pfs_group        = "None"
    sa_lifetime      = 27000
  }
}