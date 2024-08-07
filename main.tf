provider "aws" {
 region = "us-east-1"
}

variable "region" {
  default = "us-east-1"
}

variable "project" {
  default = "django_project"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
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


resource "aws_security_group" "allow_ssh" {
  vpc_id = aws_vpc.main.id

  ingress {
     description = "Allow HTTP"
     from_port   = 8000
     to_port     = 8000
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "django" {
  ami           = "ami-04a81a99f5ec58529"
  instance_type = "t2.micro"
  key_name = "TEST1"
  security_groups = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true
  subnet_id     = aws_subnet.main.id


  tags = {
    Name = "DjangoProject"
  }

  user_data = <<-EOF
              #!/bin/bash

                   sudo apt update
                   sudo apt upgrade -y
                   python3 --version
                   sudo apt install python3-pip -y
                   pip list
                   pip install virtualenv -y
                   sudo apt install python3-virtualenv -y
                   sudo apt install python3-venv -y
                   python3 -m venv vaseem
                   ls
                   cd vaseem
                   ls
                   cd bin
                   source activate
                   cd ..
                   pip install django
                   git clone https://github.com/vaseem2914/Django-WebApp.git
				           ls
                   cd Django-WebApp/
                   ls
                   python manage.py makemigrations
                   pip install django-crispy-forms
                   python manage.py makemigrations
                   pip install easy-pil
                   python manage.py makemigrations
                   python manage.py migrate
                   python manage.py runserver 0.0.0.0:8000

              EOF
}
