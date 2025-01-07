# AWS VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

# AWS Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "private-subnet"
  }
}

# AWS Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# AWS Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# AWS Customer Gateway (pointing to Azure VPN Gateway)
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
  vpn_gateway_id      = aws_vpn_gateway.main.id
  customer_gateway_id = aws_customer_gateway.azure.id
  type               = "ipsec.1"
  static_routes_only = true

  tags = {
    Name = "aws-to-azure"
  }
}

# Azure Resource Group
resource "azurerm_resource_group" "main" {
  name     = "main-rg"
  location = "West US 2"
}

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

# Azure Gateway Subnet (required for VPN Gateway)
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.255.0/24"]
}

resource "azurerm_public_ip" "vpn_gateway" {
  name                = "vpn-gateway-ip"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure VPN Gateway
resource "azurerm_virtual_network_gateway" "main" {
  name                = "main-vpn-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp   = false
  sku          = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id         = azurerm_public_ip.vpn_gateway.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway.id
  }
}

# Azure Local Network Gateway (pointing to AWS VPN Gateway)
resource "azurerm_local_network_gateway" "aws" {
  name                = "aws-local-gateway"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  gateway_address     = aws_vpn_connection.to_azure.tunnel1_address

  address_space = [
    aws_vpc.main.cidr_block
  ]
}

# Azure VPN Connection
resource "azurerm_virtual_network_gateway_connection" "to_aws" {
  name                = "to-aws"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.main.id
  local_network_gateway_id   = azurerm_local_network_gateway.aws.id

  shared_key = aws_vpn_connection.to_azure.tunnel1_preshared_key
}

# Outputs
output "aws_vpn_connection_tunnel1_address" {
  value = aws_vpn_connection.to_azure.tunnel1_address
}

output "aws_vpn_connection_tunnel1_psk" {
  value     = aws_vpn_connection.to_azure.tunnel1_preshared_key
  sensitive = true
}

output "azure_vpn_gateway_public_ip" {
  value = azurerm_public_ip.vpn_gateway.ip_address
}