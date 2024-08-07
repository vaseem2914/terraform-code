provider "aws" {
 region = "us-east-1"
 }
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
 vpc_id            = aws_vpc.main.id
 cidr_block        = "10.0.1.0/24"
 map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
 vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
 vpc_id = aws_vpc.main.id

 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
}

resource "aws_route_table_association" "a" {
 subnet_id      = aws_subnet.main.id
 route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "nginx_sg" {
 vpc_id      = aws_vpc.main.id
 name        = "nginx_sg"
 description = "Allow HTTP and SSH traffic"

 ingress {
   description = "Allow HTTP"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 ingress {
  description = "Allow SSH"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

 egress {
   description = "Allow all outbound"
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}
resource "aws_instance" "nginx" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
 key_name = "TEST1"
 vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
 associate_public_ip_address = true
 subnet_id                   = aws_subnet.main.id

 user_data = <<-EOF
               #!/bin/bash
               sudo apt update
               sudo apt upgrade -y
               sudo apt install nginx -y
               sudo systemctl enable nginx.service
               sudo systemctl start nginx.service
               /var/www/html/index.html
             EOF

 tags = {
   Name = "nginx-server4"
 }
}
