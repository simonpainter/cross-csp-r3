# AWS-Azure Hybrid DNS Lab

This Terraform configuration establishes a hybrid cloud environment between AWS and Azure with cross-cloud DNS resolution capabilities. The lab demonstrates how to set up private DNS resolution between cloud providers using Azure Private DNS Resolver and AWS Route53 Resolver.

## Architecture Overview

### Network Configuration

- AWS VPC: 10.0.0.0/16
  - Public subnet: 10.0.1.0/24
  - Private subnet: 10.0.2.0/24
- Azure VNet: 172.16.0.0/16
  - Main subnet: 172.16.1.0/24
  - DNS Resolver Inbound subnet: 172.16.2.0/24
  - DNS Resolver Outbound subnet: 172.16.3.0/24
  - Gateway subnet: 172.16.255.0/24

### Components

#### AWS Resources

- VPC with public and private subnets
- Route53 private hosted zone (internal.example.com)
- Route53 Resolver inbound endpoint
- Test VM in private subnet with Apache

#### Azure Resources

- Virtual Network with dedicated subnets
- Private DNS Resolver with inbound and outbound endpoints
- DNS forwarding ruleset for internal.example.com
- Test VM with Apache

### Connectivity

- Site-to-site VPN connection between AWS and Azure
- Two VPN tunnels for redundancy
- Custom route tables for cross-cloud routing

## DNS Resolution Flow

```
Azure                                      AWS
┌──────────────────────────────┐          ┌──────────────────────────────┐
│                              │          │                              │
│  ┌──────────┐   Step 1       │          │                ┌──────────┐  │
│  │   VM     ├───────────┐    │          │                │   VM     │  │
│  └──────────┘           │    │          │                └────┬─────┘  │
│  172.16.1.0/24          \/   │          │                     │        │
│                    ┌─────────┐          │                     │        │
│                    │  Azure  │          │                     │        │
│               ┌────┤  DNS    │          │                     │        │
│   Step 2      │    │Resolver │          │                     │        │
│               \/   └─────────┘          │                     │        │
│         ┌──────────┐                    │                     │        │
│         │ Outbound │     Step 3         │     Step 4          │        │
│         │ Endpoint ├────────────────────┼──────────┐          │        │
│         └──────────┘                    │          \/         │        │
│         172.16.3.0/24                   │    ┌───────────┐    │        │
│                /\                       │    │  Route53  │    │        │
│                │                        │    │  Resolver │    │        │
│                │                        │    │  Inbound  │    │        │
│                │                        │    └─────┬─────┘    │        │
│                │                        │          │          │        │
│                │                        │          \/         │        │
│                │                        │    ┌───────────┐    │        │
│                │         Step 8         │    │  Private  │    │        │
│                └────────────────────────┼────┤  Route53  │    │        │
│                                         │    │   Zone    ├────┘        │
└──────────────────────────────┘          │    └───────────┘             │
                                          └──────────────────────────────┘
```

DNS Resolution Steps:

1. Azure VM queries systemd-resolved (127.0.0.53)
2. Query reaches Azure DNS Resolver
3. Azure Outbound Endpoint forwards query for internal.example.com
4. AWS Route53 Resolver Inbound receives query
5. Route53 private hosted zone resolves record
6. Response returns to Route53 Resolver Inbound
7. Response returns to Azure Outbound Endpoint
8. Response returns through Azure DNS Resolver to VM

## Prerequisites

- AWS Account with appropriate permissions
- Azure Subscription with appropriate permissions
- Terraform 0.14.9 or later

## Required Variables

### AWS Variables

- `access_key`: AWS access key
- `secret_key`: AWS secret key
- `region`: AWS region (default: us-west-1)

### Azure Variables

- `client_secret`: Azure service principal client secret
- `client_id`: Azure service principal client ID
- `tenant_id`: Azure tenant ID
- `subscription_id`: Azure subscription ID

## Usage

1. Clone the repository
2. Configure AWS and Azure authentication
3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Apply the configuration:

   ```bash
   terraform apply
   ```

## Testing DNS Resolution

After deployment:

1. SSH into the Azure VM
2. Test DNS resolution:

   ```bash
   dig aws-vm.internal.example.com
   ```

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Notes

- Default region is us-west-1 for AWS and West US 2 for Azure
- Test VMs are deployed with Apache for basic connectivity testing
- Both VMs are accessible via SSH using the specified public key