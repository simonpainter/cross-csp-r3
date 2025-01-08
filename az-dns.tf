# DNS Resolver
resource "azurerm_private_dns_resolver" "main" {
    name                = "dns-resolver"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    virtual_network_id  = azurerm_virtual_network.main.id
}

# Inbound Endpoint
resource "azurerm_private_dns_resolver_inbound_endpoint" "main" {
    name                    = "inbound-endpoint"
    private_dns_resolver_id = azurerm_private_dns_resolver.main.id
    location                = azurerm_resource_group.main.location
    
    ip_configurations {
        subnet_id = azurerm_subnet.dns_resolver_inbound.id
        private_ip_allocation_method = "Dynamic"
    }
}

# Outbound Endpoint for forwarding to AWS
resource "azurerm_private_dns_resolver_outbound_endpoint" "main" {
    name                    = "outbound-endpoint"
    private_dns_resolver_id = azurerm_private_dns_resolver.main.id
    location                = azurerm_resource_group.main.location
    subnet_id               = azurerm_subnet.dns_resolver_outbound.id
}

# DNS Forwarding Ruleset
resource "azurerm_private_dns_resolver_dns_forwarding_ruleset" "main" {
    name                = "aws-forwarding-ruleset"
    resource_group_name = azurerm_resource_group.main.name
    location            = azurerm_resource_group.main.location
    
    private_dns_resolver_outbound_endpoint_ids = [
        azurerm_private_dns_resolver_outbound_endpoint.main.id
    ]
}

# Link Ruleset to VNet
resource "azurerm_private_dns_resolver_virtual_network_link" "main" {
    name                      = "vnet-link"
    dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.main.id
    virtual_network_id        = azurerm_virtual_network.main.id
}

# Forwarding Rule for internal.example.com to AWS

resource "azurerm_private_dns_resolver_forwarding_rule" "aws" {
    name                      = "aws-rule"
    dns_forwarding_ruleset_id = azurerm_private_dns_resolver_dns_forwarding_ruleset.main.id
    domain_name              = "internal.example.com."
    enabled                  = true
    
    dynamic "target_dns_servers" {
        for_each = aws_route53_resolver_endpoint.inbound.ip_address[*].ip
        content {
            ip_address = target_dns_servers.value
            port       = 53
        }
    }
}