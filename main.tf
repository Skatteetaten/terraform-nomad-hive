locals {
  datacenters     = join(",", var.nomad_datacenters)
  buckets         = var.hive_bucket # output variable for presto
  hive_env_vars   = join("\n",
    concat([
      "JUST_EXAMPLE_ENV=some-value",
    ], var.hive_container_environment_variables)
  )

  template_remote_docker_image  = file("${path.module}/conf/nomad/hive.hcl")
  template_local_docker_image   = file("${path.module}/conf/nomad/hive_local.hcl")
}

data "template_file" "template_nomad_job_hive" {

  template = var.nomad_job_switch_local ? local.template_local_docker_image : local.template_remote_docker_image

  vars      = {
    service_name              = var.hive_service_name
    datacenters               = local.datacenters
    namespace                 = var.nomad_namespace

    image                     = var.hive_docker_image # !NB: no affect to `hive_local.hcl`
    port                      = var.hive_container_port
    envs                      = local.hive_env_vars

    hive_bucket               = var.hive_bucket.hive
    default_bucket            = var.hive_bucket.default

    # postgres
    postgres_service_name     = var.postgres_service.service_name
    postgres_local_bind_port  = var.postgres_service.port
    postgres_database_name    = var.postgres_service.database_name
    postgres_username         = var.postgres_service.username
    postgres_password         = var.postgres_service.password

    # minio
    minio_service_name        = var.minio_service.service_name
    minio_local_bind_port     = var.minio_service.port
    minio_access_key          = var.minio_service.access_key
    minio_secret_key          = var.minio_service.secret_key
  }
}

resource "nomad_job" "nomad_job_hive" {
  jobspec = data.template_file.template_nomad_job_hive.rendered
  detach  = false
}