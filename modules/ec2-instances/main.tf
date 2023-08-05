
# ---------------------------------------
# Define una instancia EC" con AMI ubuntu
# ---------------------------------------
resource "aws_instance" "server" {
  for_each = var.servers

  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers soy ${each.value.name}!" > index.html
              nohup busybox httpd -f -p ${var.port_server} &
              EOF

  tags = {
    Name = each.value.name
    Env  = var.env
  }
}


# ------------------------------------------------------
# Define un grupo de seguridad con acceso al puerto 8080
# ------------------------------------------------------
resource "aws_security_group" "my_security_group" {
  name = "my_server_sg-${var.env}"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 8080 desde el exterior"
    from_port   = var.port_server
    to_port     = var.port_server
    protocol    = "TCP"
  }
}
