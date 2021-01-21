resource "aws_lb" "keycloak_lb" {
  name               = format("%s-keycloak", var.environment)
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.keycloak_loadbalancer_sg.id]
  subnets = var.pub_subnet_ids

  enable_deletion_protection = true
  enable_http2 = true

  tags = {
    Environment = var.environment
    UrEnv = var.environment
  }

}

resource "aws_lb_target_group" "keycloak-tg" {
  name     = "keycloak-${var.environment}-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    timeout             = 5
    interval            = 10
    path = "/"
    matcher = "200-299"
  }
}

resource "aws_lb_listener" "keycloak" {
  load_balancer_arn = aws_lb.keycloak_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.keycloak-tg.arn
  }
}

resource "aws_security_group" "keycloak_loadbalancer_sg" {
  name = "keycloak-${var.environment}-loadbalancer-sg"
  description = "Keycloak LB access"
  vpc_id = var.vpc_id

  tags = {
    Name = "keycloak-${var.environment}-loadbalancer-sg"
    Environment = var.environment
    UrEnv = var.environment
  }

  # ssh access from everywhere
  ingress {
    description = "main access route"
    from_port         = 443
    to_port           = 443
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    description = ""
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}

