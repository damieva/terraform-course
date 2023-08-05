// Vbles para el modulo loadbalancer

variable "subnet_ids" {
  description = "Todos los ids de las subnets donde provisionamos el loadBalancer"
  type        = set(string)
}

variable "instance_ids" {
  description = "ids de las instancias de EC2"
  type        = list(string)
}

variable "port_lb" {
  description = "LB port"
  type        = number
  default     = 80
}

variable "port_server" {
  description = "Instancies port"
  type        = number
  default     = 8080
  validation {
    condition     = var.port_server > 0 && var.port_server <= 65536
    error_message = "The server port has to be in range 1-65536"
  }
}

variable "env" {
  description = "entorno en el que estamos trabajando"
  type        = string
  default     = ""
}

