resource "aws_db_instance" "main-db" {
  instance_class = var.db_instance_type
  db_subnet_group_name = aws_db_subnet_group.main-db-subnets.name
  multi_az = true
  allocated_storage = 20
  max_allocated_storage = 100
  backup_retention_period = 3
  deletion_protection = true
  storage_type = "gp2"
  engine = "mariadb"
  engine_version = "10.4"
  username = "keycloak"
  password = random_password.db-admin-password.result
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  identifier = "maria-${var.environment}-keycloak"
}


resource "aws_db_subnet_group" "main-db-subnets" {
  subnet_ids = var.db_subnet_ids
  name = "${var.environment}-keycloak-db-subnets"
}

resource "random_password" "db-admin-password" {
  length = 16
  special = false
}

resource "aws_security_group" "db_security_group" {
  name = "keycloak-db-${var.environment}-security-group"
  description = "access to keycloaks DB"
  vpc_id = var.vpc_id

  tags = {
    Name = "keycload-db-${var.environment}-security-group"
    UrEnv = var.environment
  }

  ingress {
    description = ""
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = [aws_security_group.keycloak_security_group.id]
  }

  ingress {
    description = ""
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = local.source_cidr_blocks
  }
}


provider "mysql" {
  endpoint = "${aws_db_instance.main-db.address}:3306"
  username = "keycloak"
  password = random_password.db-admin-password.result
}


resource "mysql_database" "keycloak" {
  name = "keycloak"
}




