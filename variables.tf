# Nomad
variable "nomad_provider_address" {
  type        = string
  description = "Nomad address"
  default     = "http://127.0.0.1:4646"
}
variable "nomad_datacenters" {
  type        = list(string)
  description = "Nomad data centers"
  default     = ["dc1"]
}
variable "nomad_namespace" {
  type        = string
  description = "[Enterprise] Nomad namespace"
  default     = "default"
}

# Hive
variable "hive_service_name" {
  type        = string
  description = "Hive service name"
  default     = "hive-metastore"
}

variable "hive_container_port" {
  type        = number
  description = "Hive port"
  default     = 9083
}

variable "hive_container_environment_variables" {
  type        = list(string)
  description = "Hive environment variables"
  default     = [""]
}

variable "hive_bucket" {
  type = object({
    default     = string,
    hive        = string
  })
  description = "Hive requires minio buckets"
}

# Minio
variable "minio_service" {
  type = object({
    service_name = string,
    port         = number,
    access_key   = string,
    secret_key   = string,
  })
  description = "Minio data-object contains service_name, port, access_key and secret_key"
}

# Postgres
variable "postgres_service" {
  type = object({
    service_name  = string,
    port          = number,
    database_name = string,
    username      = string,
    password      = string
  })
  description = "Postgres data-object contains service_name, port, database_name, username and password"
}

