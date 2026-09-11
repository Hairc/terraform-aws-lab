terraform {
  backend "s3" {
    bucket = "bucket-lab-pietro-rusconi"
    key    = "prod/terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" #cidr notation 32-16=16 available bits for hosts (2^16 IPs)

  tags = {
    Name = "VPC-Lab"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

#Public subnet
resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

#Association and Route Table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "my_association" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}

#Firewall (Security Group)
resource "aws_security_group" "my_sg" {
  name        = "sg_lab"
  description = "Allow SSH e HTTP"
  vpc_id      = aws_vpc.my_vpc.id

  #Entry rule for SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #WARNING: in a real enviroment limit this to own IP/32
  }

  #Entry rule for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Exit Rule (everything open)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Code to find latest ubuntu version
data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"] #Canonical official ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

#Server (EC2)
resource "aws_instance" "my_server" {
  ami                    = data.aws_ami.ubuntu_latest.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.my_subnet.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "Server-Lab"
  }

  #Intall and start docker during the first server launch
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install docker.io -y
              systemctl start docker
              systemctl enable docker
              docker run -d -p 80:80 nginx
              EOF
}