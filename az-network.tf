# Azure Virtual Network
resource "azurerm_virtual_network" "main" {
    name                = "main-vnet"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    address_space       = ["172.16.0.0/16"]
    
    # Use Azure-provided DNS server
    dns_servers = []  # Empty list means use Azure DNS
}

# Main Subnet
resource "azurerm_subnet" "main" {
    name                 = "main-subnet"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["172.16.1.0/24"]
}

# DNS Resolver Inbound Subnet
resource "azurerm_subnet" "dns_resolver_inbound" {
    name                                           = "dns-resolver-inbound"
    resource_group_name                            = "main-rg"
    virtual_network_name                           = "main-vnet"
    address_prefixes                               = ["172.16.2.0/24"]
    delegation {
        name = "Microsoft.Network.dnsResolvers"
        service_delegation {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}

# DNS Resolver Outbound Subnet
resource "azurerm_subnet" "dns_resolver_outbound" {
    name                                           = "dns-resolver-outbound"
    resource_group_name                            = azurerm_resource_group.main.name
    virtual_network_name                           = azurerm_virtual_network.main.name
    address_prefixes                               = ["172.16.3.0/24"]
    delegation {
        name = "Microsoft.Network.dnsResolvers"
        service_delegation {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
    }
}


# Azure Gateway Subnet
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["172.16.255.0/24"]
}