# Private Route53 zone
resource "aws_route53_zone" "private" {
  name = "internal.example.com"
  
  vpc {
    vpc_id = aws_vpc.main.id
  }

  tags = {
    Name = "private-zone"
  }
}

# Example DNS record for AWS EC2
resource "aws_route53_record" "aws_vm" {
  zone_id = aws_route53_zone.private.id
  name    = "aws-vm.internal.example.com"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.test_vm.private_ip]
}




# AWS Route 53 Resolver Inbound Endpoint
resource "aws_route53_resolver_endpoint" "inbound" {
  name      = "inbound-endpoint"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.dns_resolver.id]

  ip_address {
    subnet_id = aws_subnet.private.id
  }

  ip_address {
    subnet_id = aws_subnet.public.id
  }

  tags = {
    Name = "inbound-resolver"
  }
}

# Security group for DNS resolver
resource "aws_security_group" "dns_resolver" {
  name        = "dns-resolver-sg"
  description = "Security group for Route 53 Resolver endpoint"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]  # Azure VNet CIDR
  }

  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["172.16.0.0/16"]  # Azure VNet CIDR
  }

  tags = {
    Name = "dns-resolver-sg"
  }
}