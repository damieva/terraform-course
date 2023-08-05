output "instance_ids" {
  description = "valores de todos los IDs de las instancias"
  value       = [for server in aws_instance.server : server.id]
}
