job "${service_name}" {

  type = "service"
  datacenters = "${datacenters}"
  namespace = "${namespace}"

  update {
    max_parallel      = 1
    health_check      = "checks"
    min_healthy_time  = "10s"
    healthy_deadline  = "12m"
    progress_deadline = "15m"
%{ if use_canary }
    canary            = 1
    auto_promote      = true
    auto_revert       = true
%{ endif }
    stagger           = "30s"
  }

  group "metastoreserver" {
    count = 1

    service {
      name = "${service_name}"
      port = "${port}"

      check {
        name = "beeline"
        type = "script"
        task = "metastoreserver"
        command = "/bin/bash"
        args = [
          "-c",
          "beeline -u jdbc:hive2:// -e \"SHOW DATABASES;\" &> /tmp/check_script_beeline_metastoreserver && echo \"return code $?\""]
        interval = "30s"
        timeout = "120s"
      }

      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name  = "${postgres_service_name}"
              local_bind_port   = "${postgres_local_bind_port}"
            }
            upstreams {
              destination_name  = "${minio_service_name}"
              local_bind_port   = "${minio_local_bind_port}"
            }
          }
        }
        sidecar_task {
          driver = "docker"
          resources {
            cpu = "${cpu_proxy}"
            memory = "${memory_proxy}"
          }
        }
      }
    }

    network {
      mode = "bridge"
    }

    task "waitfor-hive-database" {
      restart {
        attempts = 5
        delay    = "15s"
      }
      lifecycle {
        hook = "prestart"
      }
      driver = "docker"
      resources {
        memory = 32
      }
      config {
        image = "consul:latest"
        entrypoint = ["/bin/sh"]
        args = ["-c", "jq </local/service.json -e '.[].Status|select(. == \"passing\")'"]
        volumes = ["tmp/service.json:/local/service.json" ]
      }
      template {
        destination = "tmp/service.json"
        data = <<EOH
          {{- service "${postgres_service_name}" | toJSON -}}
        EOH
      }
    }

    task "metastoreserver" {
      driver = "docker"

%{ if local_docker_image }
      artifact {
        source = "s3::http://127.0.0.1:9000/dev/tmp/hive_local.tar"
        options {
          aws_access_key_id     = "minioadmin"
          aws_access_key_secret = "minioadmin"
        }
      }
      config {
        load = "hive_local.tar"
        image = "hive_local_image:local"
%{ else }
      config {
        image = "${image}"
%{ endif }
        command = "hivemetastore"
      }

      resources {
        cpu = "${cpu}"
        memory = "${memory}"
      }

      logs {
        max_files = 10
        max_file_size = 2
      }

      template {
        destination = "local/config.env"
        env = true
        data = <<EOH
HIVE_SITE_CONF_javax_jdo_option_ConnectionURL="jdbc:postgresql://{{ env "NOMAD_UPSTREAM_ADDR_${postgres_service_name}" }}/${postgres_database_name}"
HIVE_SITE_CONF_javax_jdo_option_ConnectionDriverName="org.postgresql.Driver"
HIVE_SITE_CONF_datanucleus_autoCreateSchema=false
HIVE_SITE_CONF_hive_metastore_uris="thrift://127.0.0.1:9083"
HIVE_SITE_CONF_hive_metastore_schema_verification=true
HIVE_SITE_CONF_hive_execution_engine="mr"
HIVE_SITE_CONF_hive_support_concurrency=false
HIVE_SITE_CONF_hive_driver_parallel_compilation=true
HIVE_SITE_CONF_hive_metastore_warehouse_dir="s3a://${hive_bucket}/warehouse"
HIVE_SITE_CONF_hive_metastore_event_db_notification_api_auth=false
CORE_CONF_fs_defaultFS = "s3a://${default_bucket}"
CORE_CONF_fs_s3a_connection_ssl_enabled = false
CORE_CONF_fs_s3a_endpoint = "http://{{ env "NOMAD_UPSTREAM_ADDR_${minio_service_name}" }}"
CORE_CONF_fs_s3a_path_style_access = true
        EOH
      }
      template {
        destination = "local/additional.env"
        env = true
        data = <<EOH
          ${envs}
        EOH
      }
      template {
        destination = "secrets/.env"
        env = true
        data = <<EOH
          CORE_CONF_fs_s3a_access_key = "${minio_access_key}"
          CORE_CONF_fs_s3a_secret_key = "${minio_secret_key}"
          HIVE_SITE_CONF_javax_jdo_option_ConnectionUserName="${postgres_username}"
          HIVE_SITE_CONF_javax_jdo_option_ConnectionPassword="${postgres_password}"
        EOH
      }
    }
  }
}
