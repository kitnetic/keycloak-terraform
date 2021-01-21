variable "keycloak_version" {
  type = string
}

variable "ami_owner" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "svc_subnet_ids" {
  type = list(string)
}

variable "pub_subnet_ids" {
  type = list(string)
}

variable "keycloak_ping_bucket" {
  type = string
}

variable "addiontal_cidrs_with_access" {
  type = list(string)
}

variable "keycloak_instance_type" {
  type = string
  default = "t3a.medium"
}

variable "db_instance_type" {
  type = string
  default = "db.t3.medium"
}

variable "additional_security_groups" {
  type = list(string)
  default = []
}

variable "ssh_key_name" {
  type = string
}

variable "certificate_arn" {
  type = string
}