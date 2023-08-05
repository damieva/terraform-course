# terraform-course
Udemy terraform course

# Create AWS user:
 1. Create user and attach policy in aws management console
 2. Create an access key for this user
 3. Type 'aws configure --profile my_infra' to set up our profile in our laptop
 4. Set the environment variable: 'export AWS_PROFILE=my_infra' to switch the proper profile.
 5. Test all: 'aws sts get-caller-identity'

# Terraform commands:
    - terraform init
    - terraform plan -var-file "variables.tfvars"
    - terraform apply -var-file "variables.tfvars"
    - terraform destroy: destruye todos los objetos que tenemos en la configuracion de terraform
    - terraform validate: validaciond sintactica del codigo
    - terraform format: ctrl + shift + I


Revisar system manager
Revisar porque no llegamos al puerto 8080

Los providers son plugins para interactuar con APIs remotas.
Un recurso nos define un elemento en concreto.
Hay un tipo de provider concreto que es el provisioner que nos permitirá ejecutar scripts en los recursos creados.

Terraform.lock.hcl: este fichero lo crea el core de terraform al ejecutar 'terraform init' para que si estamos compartiendo el codigo con mas gente en un repo de git, todos utilicemos la misma version de los providers. Para actualizar estas versiones haremos 'terraform init -upgrade'

Carpeta .terraform: se descargarán ahí los binarios (providers) de los plugin que usemos. Se descargarán siempre que hagamos 'terraform init'

terraform.tfstate.backup: cada vez que hacemos terraform apply con cambios aactualizar, el tfstate queda actualizado a la ultima version y el backup tiene la version anterior a la ultima por si surge algun problema (corrupcion del tfstate) y hay q hacer rollback.

Outputs: ver valores que crea AWS (identificadores,etc..) directamente por la consola en el log de terraform.

ELB y ALB: Elastic y Application load balancer.

Normalmente en un entorno empresarial, las VM pertenecen a una VPC privada por lo tanto ninguna tendría acceso directamente al exterior. En este proyecto por simplicidad se quedara así

Por defecto AWS nos crea una subnet en cada AZ.

Al desplegar 2 instancias en distintas AZs vamos a pasarle el ID de la subnet.

Terraform datasources: bloque de codigo que nos permitirá hace queries de datos que no estamos manejando desde terraform, por ejemplo: IDs de las subnets.

Por defecto AWS genera los recursos totalmente hermeticos y necesitamos definir SGs para acceder a ellos (me refiero a EC2 y ELBs/ALBs)

TargetGroup: objeto que identifica instancias que ve el balanceador para enrutar trafico
  -> aws_lb_target_group: grupo objetos (por ejemplo servidores) de destino
  -> aws_lb_target_group_attachment: endpoints
  -> aws_lb_listener: relacion de las 2 anteriores

# Terraform vars:
  - fichero variables.tf
  - tipos simples y compuestos
  - palabra reservada var
  - necesitamos un fichero variables.tf(prototipo) y otro .tfvars(valores)
  - terraform plan -var-file "variables.tfvars"
  - tambien podriamos definir los valores en un fichero formato json: variables.tfvars.json
  - se podria definir una cualquier variable como una variable de entorno: TF_VAR_port_server=8080 terraform apply
  - precedencia de mas a menos:
      1. -var/-var-file
      2. .tfvars
      3. .tfvars.json
      3. vble de entorno
  - podemos definir una vble de tipo 'any' y el tipo se le dara en la primera asignacion (tipado dinamico).
    en el caso de usar una lista de any cogera el tipo mas generico, que seria el string.
  - Ejemplo de bloque de definicion de una vble:
```
variable "instance_type" {
  description = "type of EC2 instance"
  type        = string
  default     = "t2.micro"
}
```
  - Podríamos elegir el valor de una variable en funcion de la key que queramos seleccionar. Por Ejemplo:
```
ami                    = var.ubuntu_ami["eu-west-2"]
---
variable "ubuntu_ami" {
  description = "AMI per region"
  type        = map(string)
  default = {
    "eu-west-1" = "ami-0136ddddd07f0584f"
    "eu-west-2" = "ami-007ec828a062d87a5"
  }
}
```
  - Podriamos añadir un bloque 'validation' en la definicion de la variable para mostrar un mensaje en el caso de introducir un valor erroneo de la misma. Por ejemplo:
```
variable "port_server" {
  description = "Instancies port"
  type        = number
  default     = 8080
  validation {
    condition = var.port_server > 0 && var.port_server <= 65536
    error_message = "The server port has to be in range 1-65536"
  }
}
```

# Terraform loops: (count and for_each)
  - Count:
    * Repite un recurso n veces
    * Un recurso se convierte en una lista de recursos. Ej: - aws_instance.server[0] y - aws_instance.server[1]
    * El problema de el bucle count es que si utilizamos la siguiente lista de 3 variables ['pepe', 'jose', 'luis'] y borramos uno de ellos ['pepe', luis], en este caso se eliminara jose y tb luis porque el lugar de luis en la lista no sera el mismo que antes.
    * tenemos que utilizar el metargumento count, la funcion lenght y otro metargumento count.index de la siguiente forma:
```
variable "usuarios" {
  description = "Nombre de usuarios IAM"
  type        = list(string)
}

resource "aws_iam_user" "ejemplo" {
  count = length(var.usuarios)

  name = "usuario-${var.usuarios[count.index]}"
}
```

  - For_each:
    * Itera sobre un set o un map
    * Las variables han de ser totalmente conocidas en el momento del terraform apply, por lo tanto no podremos hacer un for_each sobre un grupo de recursos que aun no ha sido creado (Ejemplo: los IDs de las instancias en el objeto aws_lb_target_group_attachment no han sido creadas antes de pasarselas en un for_each a este objeto, por eso no nos deja crearlo -> solucion: implementarlo con un bucle count o utilizar targets).
    * Podemos usar each.key y each.value como metargumentos para acceder a los valores actuales.
    * Un recurso en vez de convertirse en una lista de recursos se convertira en un mapa de recursos: - aws_instance.servidor["server-1"] y - aws_instance.servidor["server-2"]
    * Ejemplo:
```
variable "usuarios" {
  description = "Nombre usuarios IAM"
  type        = set(string)
}

resource "aws_iam_user" "ejemplo" {
  for_each = var.usuarios

  name = "usuario-${each.value}"
}
```

# Expresiones splat:
  * sirven para iterar sobre un elemento lista: por ejemplo cuando solo uno de los parametros de un objeto nos requiere una lista.
```
resource "aws_lb" "alb" {
  subnets            = [for subnet in data.aws_subnet.public_subnet : subnet.id]
}

```

# Vbles locales:
  - se pueden referenciar desde otro fichero siempre que esten en el mismo directorio
  - Ejemplo:
```
locals {
  region = "eu-west-1"
  ami    = var.ubuntu_ami[local.region]
}

provider "aws" {
  region = local.region
}
```

# Terraform Modules:
  - son funciones abstractas que pasandoles una serie de parametros nos crean recursos, por ejemplo: EC2-instances o ELB, EKS, etc..
  - módulos open-source y verificados por Hashicorp: https://registry.terraform.io/browse/modules

# ToDo:
  - poner nuestra infra en una vpc sin desde internet

# Commands to run the infra:
  - export AWS_PROFILE=my_infra
  - cd env/dev && terraform init
  - terraform validate
  - terraform plan
  - terraform apply