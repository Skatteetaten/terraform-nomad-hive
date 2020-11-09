module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.3.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence-minio"

  # minio
  service_name    = "minio"
  host            = "127.0.0.1"
  port            = 9000
  container_image = "minio/minio:latest" # todo: avoid using tag latest in future releases
  # user provided  credentials
  vault_secret = {
    use_vault_provider   = false,
    vault_kv_policy_name = "",
    vault_kv_path        = "",
    vault_kv_access_key  = "",
    vault_kv_secret_key  = ""
  }
  access_key = "minio"
  secret_key = "minio123"

  data_dir                        = "/minio/data"
  buckets                         = ["default", "hive"]
  container_environment_variables = ["JUST_EXAMPLE_VAR1=some-value", "ANOTHER_EXAMPLE2=some-other-value"]
  use_host_volume                 = false
  use_canary                      = true

  # mc
  mc_service_name                    = "mc"
  mc_container_image                 = "minio/mc:latest" # todo: avoid using tag latest in future releases
  mc_container_environment_variables = ["JUST_EXAMPLE_VAR3=some-value", "ANOTHER_EXAMPLE4=some-other-value"]
}

module "postgres" {
  source = "github.com/fredrikhgrelland/terraform-nomad-postgres.git?ref=0.3.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"
  nomad_host_volume = "persistence-postgres"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  vault_secret                    = {
    use_vault_provider     = false,
    vault_kv_policy_name   = "",
    vault_kv_path          = "",
    vault_kv_username_name = "",
    vault_kv_password_name = ""
  }
  admin_user                      = "hive"
  admin_password                  = "hive"
  database                        = "metastore"
  volume_destination              = "/var/lib/postgresql/data"
  use_host_volume                 = true
  use_canary                      = true
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data/"]
}

module "hive" {
  source = "../../.."

  # nomad
  nomad_datacenters  = ["dc1"]
  nomad_namespace    = "default"
  local_docker_image = false

  # hive
  use_canary                           = false
  hive_service_name                    = "hive-metastore"
  hive_container_port                  = 9083
  hive_docker_image                    = "fredrikhgrelland/hive:3.1.0"
  hive_container_environment_variables = ["SOME_EXAMPLE=example-value"]
  resource = {
    cpu    = 500,
    memory = 1024
  }
  resource_proxy =  {
    cpu     = 200,
    memory  = 128
  }

  # hive - minio
  hive_bucket = {
    default = "default",
    hive    = "hive"
  }
  minio_service = {
    service_name = module.minio.minio_service_name,
    port         = module.minio.minio_port,
    access_key   = module.minio.minio_access_key,
    secret_key   = module.minio.minio_secret_key,
  }

  # hive - postgres
  postgres_service = {
    service_name  = module.postgres.service_name
    port          = module.postgres.port
    database_name = module.postgres.database_name
    username      = module.postgres.username
    password      = module.postgres.password
  }

  depends_on = [
    module.minio,
    module.postgres
  ]
}
