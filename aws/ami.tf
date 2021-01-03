data "aws_ami" "keycloak" {
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "tag:Name"
    values = ["Keycloak_${var.keycloak_version}"]
  }
  most_recent = true
  owners = [var.ami_owner]
}
