resource "random_password" "keycloak-admin-password" {
  length = 16
  special = false
}

resource "aws_secretsmanager_secret" "keycloak_pw_secret" {
  name = "${var.environment}-keycloak-pw"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "keycloak_pw" {
  secret_id = aws_secretsmanager_secret.keycloak_pw_secret.id
  secret_string = random_password.keycloak-admin-password.result
}


data "aws_secretsmanager_secret" "keycloakd_bucket_access" {
  name = "${var.environment}-keycloak-bucket-access"
}

data "aws_secretsmanager_secret_version" "keycloakd_bucket_access_version" {
  secret_id = data.aws_secretsmanager_secret.keycloakd_bucket_access.id
}

locals {
  source_cidr_blocks = var.addiontal_cidrs_with_access
  aws_access_key = jsondecode(data.aws_secretsmanager_secret_version.keycloakd_bucket_access_version.secret_string)["access_key"]
  aws_secret_key = jsondecode(data.aws_secretsmanager_secret_version.keycloakd_bucket_access_version.secret_string)["secret_key"]
}

resource "aws_security_group" "keycloak_security_group" {
  name = "keycloak-${var.environment}-security-group"
  description = "Keycloak ports "
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.environment}-keycloak"
    Environment = var.environment
    UrEnv = var.environment
  }

  # ssh access from everywhere
  ingress {
    description = ""
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = local.source_cidr_blocks
  }


  # intra-cluster communication
  ingress {
    description = ""
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    security_groups = []
  }

  # intra-cluster communication
  ingress {
    description = ""
    from_port         = 57600
    to_port           = 57600
    protocol          = "tcp"
    self              = true
  }

  # intra-cluster communication
  ingress {
    description = ""
    from_port         = 7600
    to_port           = 7600
    protocol          = "tcp"
    self              = true
  }

  # allow inter-cluster ping
  ingress {
    description = ""
    from_port         = 8
    to_port           = 0
    protocol          = "icmp"
    self              = true
  }

  egress {
    description = ""
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}