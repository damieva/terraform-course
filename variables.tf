variable "port_server" {
  description = "Instancies port"
  type        = number
}

variable "port_lb" {
  description = "LB port"
  type        = number
}

variable "instance_type" {
  description = "type of EC2 instance"
  type        = string
}
