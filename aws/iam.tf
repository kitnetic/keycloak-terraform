resource "aws_iam_role" "keycloak" {
  name               = "${var.environment}-keycloak-role"
  assume_role_policy = file("${path.module}/templates/ec2-role-trust-policy.json")
  tags = {
    Environment = var.environment
    UrEnv = var.environment
  }
}

/*
resource "aws_iam_role_policy" "keycloakd-sample-policy" {
  name     = "${var.environment}-keycloak-sample-policy"
  policy   = file("${path.module}/templates/sample.json")
  role     = aws_iam_role.keycloak.id
}
*/

resource "aws_iam_role_policy_attachment" "cloudwatchagent" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role = aws_iam_role.keycloak.id
}

resource "aws_iam_instance_profile" "keycloak" {
  name = "${var.environment}-elasticsearch-keycloak-profile"
  path = "/"
  role = aws_iam_role.keycloak.name
}