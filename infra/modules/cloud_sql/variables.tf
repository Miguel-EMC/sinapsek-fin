variable "project_id" {}
variable "region" {}
variable "environment" {}
variable "vpc_id" {}
variable "db_depends_on" {
  type    = any
  default = null
}
