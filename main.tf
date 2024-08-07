provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-04a81a99f5ec58529" # Update with your preferred AMI
  instance_type = "t2.medium"
  key_name      = "TEST1"

  tags = {
    Name = "Example Instance"
  }
}
