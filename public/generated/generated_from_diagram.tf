provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name   = "VPC"
    Domain = "www.learnitguide.net"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "public_instance_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "public-instance-sg"
  description = "Allow SSH and HTTP for public instances"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Public Instance SG"
  }
}

resource "aws_security_group" "private_instance_sg" {
  vpc_id      = aws_vpc.main.id
  name        = "private-instance-sg"
  description = "Allow SSH from public instances and all internal traffic"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_instance_sg.id]
    description     = "Allow SSH from public instances"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
    description = "Allow all traffic from within VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Private Instance SG"
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "main" {
  key_name   = "my-terraform-key"
  public_key = tls_private_key.main.public_key_openssh
}

resource "local_file" "private_key" {
  content         = tls_private_key.main.private_key_pem
  filename        = "my-terraform-key.pem"
  file_permission = "0600"
}

resource "aws_instance" "public_instances" {
  count                       = 3
  ami                         = data.aws_ami.amazon_linux_2.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.public_instance_sg.id]
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Public Subnet Instance ${count.index + 1}"
  }
}

resource "aws_instance" "private_instances" {
  count                  = 3
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.private_instance_sg.id]
  key_name               = aws_key_pair.main.key_name

  tags = {
    Name = "Private Subnet Instance ${count.index + 1}"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "public_instance_public_ips" {
  description = "Public IPs of public instances"
  value       = aws_instance.public_instances[*].public_ip
}

output "private_key_path" {
  description = "Path to the generated private key file"
  value       = local_file.private_key.filename
}