output "public_dns" {
    description = "public DNS of our server-1"
    value       = "http://${aws_instance.my_server.public_dns}:8080"
}