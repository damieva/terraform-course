output "public_load-balancer" {
  description = "public DNS of our LB"
  value       = module.loadbalancers.public_load-balancer
}
