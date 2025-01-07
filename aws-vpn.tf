# AWS Customer Gateway
resource "aws_customer_gateway" "azure" {
  bgp_asn    = 65000
  ip_address = azurerm_public_ip.vpn_gateway.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "azure-cgw"
  }
}

# AWS VPN Gateway
resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-vgw"
  }
}

# AWS VPN Connection
resource "aws_vpn_connection" "to_azure" {
  vpn_gateway_id         = aws_vpn_gateway.main.id
  customer_gateway_id    = aws_customer_gateway.azure.id
  type                  = "ipsec.1"
  static_routes_only    = true
  tunnel1_preshared_key = random_password.tunnel1_psk.result
  tunnel2_preshared_key = random_password.tunnel2_psk.result

  tags = {
    Name = "aws-to-azure"
  }
}

# AWS VPN Connection Route
resource "aws_vpn_connection_route" "to_azure" {
  destination_cidr_block = "172.16.0.0/16"
  vpn_connection_id      = aws_vpn_connection.to_azure.id
}

# Output tunnel information
output "aws_tunnel1_address" {
  description = "First tunnel IP address"
  value       = aws_vpn_connection.to_azure.tunnel1_address
}

output "aws_tunnel2_address" {
  description = "Second tunnel IP address"
  value       = aws_vpn_connection.to_azure.tunnel2_address
}