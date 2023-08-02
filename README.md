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
    - terraform plan
    - terraform apply
    - terraform destroy: destruye todos los objetos que tenemos en la configuracion de terraform


Revisar system manager
Revisar porque no llegamos al puerto 8080

Los providers son plugins para interactuar con APIs remotas.
Un recurso nos define un elemento en concreto.
Hay un tipo de provider concreto que es el provisioner que nos permitirá ejecutar scripts en los recursos creados.

Terraform.lock.hcl: este fichero lo crea el core de terraform al ejecutar 'terraform init' para que si estamos compartiendo el codigo con mas gente en un repo de git, todos utilicemos la misma version de los providers. Para actualizar estas versiones haremos 'terraform init -upgrade'

Carpeta .terraform: se descargarán ahí los binarios (providers) de los plugin que usemos. Se descargarán siempre que hagamos 'terraform init'

terraform.tfstate.backup: cada vez que hacemos terraform apply con cambios aactualizar, el tfstate queda actualizado a la ultima version y el backup tiene la version anterior a la ultima por si surge algun problema (corrupcion del tfstate) y hay q hacer rollback.

Outputs: ver valores que crea AWS (identificadores,etc..) directamente por la consola en el log de terraform.