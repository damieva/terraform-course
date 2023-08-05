output "public_load-balancer" {
  description = "public DNS of our LB"
  value       = "http://${aws_lb.alb.dns_name}:${var.port_lb}"
}
