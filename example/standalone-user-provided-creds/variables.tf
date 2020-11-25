variable "nomad_acl" {
  type        = bool
  description = "Nomad ACLs enabled/disabled"
}

# No default values, check `terraform.tfvars`
variable "minio_docker_image" {
  type = string
  description = "Minio docker image"
}

variable "postgres_docker_image" {
  type = string
  description = "Postgres docker image"
}

variable "hive_docker_image" {
  type = string
  description = "Hive docker image"
}
