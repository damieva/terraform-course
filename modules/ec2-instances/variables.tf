// Vbles para el modulo ec2-instances

variable "port_server" {
  description = "Instancies port"
  type        = number
  validation {
    condition     = var.port_server > 0 && var.port_server <= 65536
    error_message = "The server port has to be in range 1-65536"
  }
}

variable "instance_type" {
  description = "type of EC2 instance"
  type        = string
}


variable "ami_id" {
  description = "Identificador de la AMI"
  type        = string
}

variable "servers" {
  description = "mapa de servidores con su correspondiente subnet_id"
  type = map(object({
    name      = string,
    subnet_id = string
  }))
}

variable "env" {
  description = "entorno en el que estamos trabajando"
  type        = string
  default     = ""
}
