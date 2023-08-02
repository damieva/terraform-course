output "public_dns_server-1" {
    description = "public DNS of our server-1"
    value       = "http://${aws_instance.server-1.public_dns}:8080"
}

output "public_dns_server-2" {
    description = "public DNS of our server-2"
    value       = "http://${aws_instance.server-2.public_dns}:8080"
}

output "public_load-balancer" {
    description = "public DNS of our LB"
    value       = "http://${aws_lb.alb.dns_name}"
}