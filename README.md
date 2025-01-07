# AWS-Azure VPN Connection

This Terraform configuration establishes a site-to-site VPN connection between AWS and Azure using their native VPN gateways.

## Network Architecture

- AWS VPC: 10.0.0.0/16
  - Public subnet: 10.0.1.0/24
  - Private subnet: 10.0.2.0/24
- Azure VNet: 172.16.0.0/16
  - Main subnet: 172.16.1.0/24
  - Gateway subnet: 172.16.255.0/24
  