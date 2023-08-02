provider "aws" {
  region="eu-west-2"
}

resource "aws_instance" "my_server" {
  ami                    = "ami-007ec828a062d87a5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  
  tags = {
    Name = "server-1"
  }
}

resource "aws_security_group" "my_security_group" {
  name = "my_server_sg"

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Acceso al puerto 8080 desde el exterior"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP" 
  }
}
