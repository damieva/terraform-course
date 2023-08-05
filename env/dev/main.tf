provider "aws" {
  region = "eu-west-2"
}

locals {
  region = "eu-west-2"
  ami    = var.ubuntu_ami[local.region]
  env    = "dev"
}

#-------------------------------------
# Data source que obtiene el id del AZ
#-------------------------------------
// Ejemplos de datasources (elementos fuera de la gestion de terraform sobre los que podemos hacer queries definiendo estos objetos):
data "aws_subnet" "public_subnet" {
  for_each = var.servers

  availability_zone = "${local.region}${each.value.az}"
}

module "ec2-instances" {
  source = "../../modules/ec2-instances"

  port_server   = 8080
  instance_type = "t2.micro"
  ami_id        = local.ami
  env           = local.env
  servers = {
    for id_ser, datos in var.servers :
    id_ser => { name = datos.name, subnet_id = data.aws_subnet.public_subnet[id_ser].id }
  }
}

module "loadbalancers" {
  source = "../../modules/loadbalancers"

  subnet_ids   = [for subnet in data.aws_subnet.public_subnet : subnet.id]
  instance_ids = module.ec2-instances.instance_ids // esto crea una dependencia entre modulos, luego el modulo ec2-instances debe ejecutarse primero
  port_lb      = 80
  port_server  = 8080
  env          = local.env
}

