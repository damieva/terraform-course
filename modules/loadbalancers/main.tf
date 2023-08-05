#------------------------------------------
# Load Balancer publico con 2 instancias
#------------------------------------------
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  name               = "terraformers-alb-${var.env}"
  security_groups    = [resource.aws_security_group.alb.id]
  subnets            = var.subnet_ids
}

#------------------------------------------
# Security group para el Load Balancer
#------------------------------------------
resource "aws_security_group" "alb" {
  name = "alb-sg-${var.env}"

  //puede ser accedido a traves del puerto 80
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 80 desde el exterior"
    from_port   = var.port_lb
    to_port     = var.port_lb
    protocol    = "TCP"
  }

  //puede acceder al puerto 8080
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Acceso al puerto 8080 desde el LB"
    from_port   = var.port_server
    to_port     = var.port_server
    protocol    = "TCP"
  }
}

data "aws_vpc" "default" {
  default = true // si ponemos este argumento a true, nos devuelve los parametros de nuestra vpc por defecto
}

#------------------------------------------
# Target Group para el Load Balancer
#------------------------------------------
// si no tenemos ningun otro recurso de ese tipo, lo podemos llamar this
resource "aws_lb_target_group" "this" {
  name     = "terraform-alb-${var.env}"
  port     = var.port_lb
  vpc_id   = data.aws_vpc.default.id
  protocol = "HTTP"

  health_check {
    enabled  = true
    matcher  = "200"
    path     = "/"
    port     = var.port_server
    protocol = "HTTP"
  }
}

#------------------------------------------
# Attachment para los servers
#------------------------------------------
resource "aws_lb_target_group_attachment" "server" {
  count = length(var.instance_ids)

  target_group_arn = aws_lb_target_group.this.arn
  target_id        = element(var.instance_ids, count.index)
  port             = var.port_server
}

#------------------------------------------
# Listener para el Load Balancer
#------------------------------------------
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.port_lb
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.this.arn
    type             = "forward"
  }
}
