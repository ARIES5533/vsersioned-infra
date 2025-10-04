# --- VPC ---
resource "aws_vpc" "infra" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "infra-vpc"
  }
}

# --- Internet Gateway ---
resource "aws_internet_gateway" "infra" {
  vpc_id = aws_vpc.infra.id

  tags = {
    Name = "infra-igw"
  }
}

# --- Public Subnet ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.infra.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "public-subnet"
  }
}

# --- Route Table & Route ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.infra.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.infra.id
  }

  tags = {
    Name = "public-route-table"
  }
}

# --- Route Table Association ---
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Group ---
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.infra.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# --- EC2 Instance ---
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = var.ec2_name
  }
}

# --- Fetch Latest Ubuntu AMI ---
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
