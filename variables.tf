variable "port_server" {
  description = "Instancies port"
  type        = number
  default     = 8080
}

variable "port_lb" {
  description = "LB port"
  type        = number
  default     = 80
}

variable "instance_type" {
  description = "type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
