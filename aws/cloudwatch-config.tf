data "template_file" "cloudwatch-config" {
  template = file("${path.module}/templates/cloudwatch-config.json")

  vars = {
    log_group_name = "ur/keycloak/${var.environment}"
  }
}

