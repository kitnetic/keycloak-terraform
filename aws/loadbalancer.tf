/*
resource "aws_elb" "es_data_nodes_lb" {

  name            = format("%s-keycloak", var.environment)
  security_groups = [aws_security_group.elasticsearch_security_group.id]
  subnets         = var.pub_subnet_ids
  internal        = false

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400


  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 9200
    lb_protocol       = "https"
    ssl_certificate_id = var.
  }

  health_check {
    healthy_threshold   = 4
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8080"
    interval            = 10
  }

  tags = {
    Name = format("%s-keycloak-lb", var.environment)
  }
}

*/