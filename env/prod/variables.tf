variable "port_server" {
  description = "Instancies port"
  type        = number
  default     = 8080
  validation {
    condition     = var.port_server > 0 && var.port_server <= 65536
    error_message = "The server port has to be in range 1-65536"
  }
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

variable "ubuntu_ami" {
  description = "AMI per region"
  type        = map(string)
  default = {
    "eu-west-1" = "ami-0136ddddd07f0584f"
    "eu-west-2" = "ami-007ec828a062d87a5"
  }
}

variable "servers" {
  description = "servers map with name and AZ"
  type = map(object({
    name = string,
    az   = string
  }))

  default = {
    "server-1" = { name = "server-1", az = "a" },
    "server-2" = { name = "server-2", az = "b" },
    "server-3" = { name = "server-3", az = "c" },
  }
}

