provider "aws" {
  region="eu-west-2"
}

// Ejemplos de datasources (elementos fuera de la gestion de terraform sobre los que podemos hacer queries definiendo estos objetos):
data "aws_subnet" "az_a" {
  availability_zone = "eu-west-2a"
}

data "aws_subnet" "az_b" {
  availability_zone = "eu-west-2b"
}

resource "aws_instance" "server-1" {
  ami                    = "ami-007ec828a062d87a5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id              = data.aws_subnet.az_a.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers soy server-1!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  
  tags = {
    Name = "server-1"
  }
}

resource "aws_instance" "server-2" {
  ami                    = "ami-007ec828a062d87a5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
  subnet_id              = data.aws_subnet.az_b.id

  user_data = <<-EOF
              #!/bin/bash
              echo "Hola Terraformers soy server-2!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  
  tags = {
    Name = "server-2"
  }
}

resource "aws_security_group" "my_security_group" {
  name = "my_server_sg"

  ingress {
    security_groups = [aws_security_group.alb.id]
    description = "Acceso al puerto 8080 desde el exterior"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP" 
  }
}

resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraformers-alb"
  security_groups    = [resource.aws_security_group.alb.id]
  subnets            = [data.aws_subnet.az_a.id, data.aws_subnet.az_b.id]
}

resource "aws_security_group" "alb" {
  name = "alb-sg"

  //puede ser accedido a traves del puerto 80
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP" 
  }

  //puede acceder al puerto 8080
  egress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Acceso al puerto 8080 desde el LB"
    from_port   = 8080
    to_port     = 8080
    protocol    = "TCP" 
  }
}

data "aws_vpc" "default" {
  default = true // si ponemos este argumento a true, nos devuelve los parametros de nuestra vpc por defecto
}

// si no tenemos ningun otro recurso de ese tipo, lo podemos llamar this
resource "aws_lb_target_group" "this" {
  name     = "terraform-alb-target-group"
  port     = 80
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = "8080"
    protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "server-1" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server-1.id
  port             = "8080"
}

resource "aws_lb_target_group_attachment" "server-2" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.server-2.id
  port             = "8080"
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}