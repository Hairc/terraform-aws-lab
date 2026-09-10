output "public_ip" {
  description = "Public IP to connect with SSH"
  value       = aws_instance.my_server.public_ip
}