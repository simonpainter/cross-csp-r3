# AWS EC2 Instance
resource "aws_security_group" "test_vm" {
  name        = "test-vm-sg"
  description = "Security group for test VM"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0", "172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "test-vm-sg"
  }
}

resource "aws_key_pair" "test_vm" {
  key_name   = "test-vm-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "test_vm" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  
  associate_public_ip_address = true
  vpc_security_group_ids     = [aws_security_group.test_vm.id]
  key_name                   = aws_key_pair.test_vm.key_name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              echo 'hello world from aws' > /var/www/html/index.html
              systemctl enable apache2
              systemctl start apache2
              EOF

  tags = {
    Name = "test-vm"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

