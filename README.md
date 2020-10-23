<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>


# Terraform-nomad-hive
This module is IaC - infrastructure as code which contains a nomad job of [hive](https://hive.apache.org/).

## Content
1. [Usage](#usage)
2. [Requirements](#requirements)
    1. [Required software](#required-software)
    2. [Providers](#providers)
3. [Inputs](#inputs)
4. [Outputs](#outputs)
5. [Modes](#modes)
6. [Example usage](#example-usage)
    1. [Verifying setup](#verifying-setup)
        1. [Data example upload](#data-example-upload)
7. [License](#license)

## Usage
The following command will run a instance of hive found in the [example](/example) folder.
```sh
make test
```

## Requirements
### Required software
- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Docker](https://www.docker.com/)
- [Consul](https://www.consul.io/)

### Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nomad\_datacenters | Nomad data centers | list(string) | ["dc1"] | no |
| nomad\_namespace | [Enterprise] Nomad namespace | string | "default" | no |
| local\_docker\_image | Switch for nomad job | bool | - | yes |
| use\_canary | Uses canary deployment for Hive | bool | false | no |
| hive\_service\_name | Hive service name | string | "hive-metastore" | no |
| hive\_container\_port | Hive container port | number | 9083 | no |
| hive\_docker\_image | Hive container image | string | "fredrikhgrelland/hive:3.1.0" | no |
| hive\_container\_environment\_variables | Hive environment variables | list(string) | [""] | no |
| resource | Resource allocations | object |  | no |
| resource.cpu | Resource allocation - cpu | number | 500 | no |
| resource.memory | Resource allocation - memory | number | 1024 | no |
| hive\_bucket | Hive requires minio buckets | obj(string) |  { default = string, hive = string } | no |
| minio\_service | Minio data-object contains service_name, port, access_key and secret_key | obj(string) | { service_name = string, port = number, access_key = string, secret_key = string } | no |
| postgres\_service | Postgres data-object contains service_name, port, database_name, username and password | obj(string) | { service_name  = string, port = number, database_name = string, username = string, password = string } | no |

## Outputs
| Name | Description | Type |
|------|-------------|------|
| service\_name | Hive service name | string |
| buckets | Minio buckets for hive | string |

## Modes
Hive can be run in two modes:
- [hivemetastore](./docker/bin/hivemetastore)
- [hiveserver](./docker/bin/hiveserver)

`NB!` current implementation supports only [`hivemetastore`](conf/nomad/hive.hcl#L99)

## Example usage
The example-code shows the minimum of what you need do to set up this module.
```hcl-terraform
module "minio" {
  source = "github.com/fredrikhgrelland/terraform-nomad-minio.git?ref=0.1.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # minio
  service_name                    = "minio"
  host                            = "127.0.0.1"
  port                            = 9000
  container_image                 = "minio/minio:latest"
  access_key                      = "minio"
  secret_key                      = "minio123"
  buckets                         = ["default", "hive"]
  container_environment_variables = ["JUST_EXAMPLE_VAR1=some-value", "ANOTHER_EXAMPLE2=some-other-value"]
  resource = {
    cpu     = 500,
    memory  = 1024
  }

  # mc
  mc_service_name                    = "mc"
  mc_container_image                 = "minio/mc:latest"
  mc_container_environment_variables = ["JUST_EXAMPLE_VAR3=some-value", "ANOTHER_EXAMPLE4=some-other-value"]
}

module "postgres" {
  source = "github.com/fredrikhgrelland/terraform-nomad-postgres.git?ref=0.1.0"

  # nomad
  nomad_datacenters = ["dc1"]
  nomad_namespace   = "default"

  # postgres
  service_name                    = "postgres"
  container_image                 = "postgres:12-alpine"
  container_port                  = 5432
  admin_user                      = "hive"
  admin_password                  = "hive"
  database                        = "metastore"
  container_environment_variables = ["PGDATA=/var/lib/postgresql/data"]
}

module "hive" {
  source = "./.."

  # nomad
  nomad_datacenters      = ["dc1"]
  nomad_namespace        = "default"
  local_docker_image     = false

  # hive
  use_canary                           = false
  hive_service_name                    = "hive-metastore"
  hive_container_port                  = 9083
  hive_docker_image                    = "fredrikhgrelland/hive:3.1.0"
  hive_container_environment_variables = ["SOME_EXAMPLE=example-value"]

  # hive - minio
  hive_bucket = {
    default     = "default",
    hive        = "hive"
  }
  minio_service = {
    service_name = module.minio.minio_service_name,
    port         = 9000,
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
```

### Verifying setup

You can verify the setup by connection to Hive using the Nomad UI at [localhost:4646](http://localhost:4646/). Follow the steps below.
1. Locate and click the *hive-metastore* service.
2. Click the *exec* button and connect to the *metastoreserver* task.
3. Run `beeline -u jdbc:hive2://` to connect to hive.
4. Run `SHOW databases;`. Your output should look like this:
```sh
OK
+----------------+
| database_name  |
+----------------+
| default        |
+----------------+
```

#### Data example upload
[example/resources/data](example) directory contains data sample to upload. You can create tables via [beeline cli](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-Beeline%E2%80%93CommandLineShell), how to use beeline-cli see section [verifying setup](#verifying-setup).

Create table `iris`
```sql
CREATE EXTERNAL TABLE iris (sepal_length DECIMAL, sepal_width DECIMAL, 
petal_length DECIMAL, petal_width DECIMAL, species STRING) 
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
LOCATION 's3a://hive/some/prefix/'
TBLPROPERTIES ("skip.header.line.count"="1");
```
Query table `iris`
```sql
SELECT * FROM default.iris LIMIT 10;
```

## License
This work is licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.
