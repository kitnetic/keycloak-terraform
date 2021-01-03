data "template_file" "data_userdata_script" {
  template = file("${path.module}/user-data/user_data.sh")

  vars = {
    keycloak_ping_bucket    = var.keycloak_ping_bucket
    keycloak_cluster_name   = var.environment
    keycloak_admin_password = random_password.keycloak-admin-password.result
    cloudwatch_config        = data.template_file.cloudwatch-config.rendered
    keycloak_db_address     = aws_db_instance.main-db.address
    keycloak_db_user        = "keycloak"
    keycloak_db_password    = random_password.db-admin-password.result
    aws_access_key          = local.aws_access_key
    aws_secret_key          = local.aws_secret_key
  }
}

resource "aws_launch_template" "keycloak_node_template" {

  default_version         = "1"
  disable_api_termination = "false"
  ebs_optimized           = "true"

  iam_instance_profile {
    name = aws_iam_instance_profile.keycloak.name
  }

  image_id      = data.aws_ami.keycloak.id
  instance_type = var.keycloak_instance_type
  key_name      = var.ssh_key_name

  monitoring {
    enabled = "true"
  }

  name_prefix = "keycloak-${var.environment}-node"
  user_data = base64encode(data.template_file.data_userdata_script.rendered)
  vpc_security_group_ids = concat(list(aws_security_group.keycloak_security_group.id), var.additional_security_groups)
}

resource "aws_autoscaling_group" "keycloak_nodes" {
  name = "keycloak-${var.environment}-nodes"
  max_size = 3
  min_size = 2
  desired_capacity = 2
  default_cooldown = 30
  force_delete = true
  launch_template {
    id = aws_launch_template.keycloak_node_template.id
  }

  vpc_zone_identifier = var.svc_subnet_ids

  // load_balancers = [aws_elb.es_data_nodes_lb[0].id]

  tag {
    key                 = "Name"
    value               = format("%s-keycloak", var.environment)
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = var.environment
    propagate_at_launch = true
  }

  tag {
    key = "UrEnv"
    value = var.environment
    propagate_at_launch = true
  }


  lifecycle {
    create_before_destroy = true
  }
}