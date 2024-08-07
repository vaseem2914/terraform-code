
output "instance_ip" {
  value = aws_instance.django.public_ip
}

