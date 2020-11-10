<!-- markdownlint-disable MD041 -->
<p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack-template" alt="Built on"><img src="https://img.shields.io/badge/Built%20from%20template-Vagrant--hashistack--template-blue?style=for-the-badge&logo=github"/></a><p align="center"><a href="https://github.com/fredrikhgrelland/vagrant-hashistack" alt="Built on"><img src="https://img.shields.io/badge/Powered%20by%20-Vagrant--hashistack-orange?style=for-the-badge&logo=vagrant"/></a></p></p>


# Terraform-nomad-hive
This module is IaC - infrastructure as code which contains a nomad job of [hive](https://hive.apache.org/).

## Content
0. [Prerequisites](#prerequisites)
1. [Requirements](#requirements)
    1. [Required modules](#required-modules)
    2. [Required software](#required-software)
3. [Compatibility](#compatibility)
4. [Providers](#providers)
5. [Usage](#usage)
    1. [Verifying setup](#verifying-setup)
        1. [Data example upload](#data-example-upload)
6. [Intentions](#intentions)
7. [Inputs](#inputs)
8. [Outputs](#outputs)
8. [Modes](#modes)
9. [Examples](#examples)
10. [Contributors](#contributors)
11. [License](#license)
12. [References](#references)

## Prerequisites

Please follow [this section in original template](https://github.com/fredrikhgrelland/vagrant-hashistack-template#install-prerequisites)

## Requirements

### Required modules

|Module|Version|
|:---|:---|
|[terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio)| 0.3.0 or newer|
|[terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres)| 0.3.0 or newer|

### Required software

- [GNU make](https://man7.org/linux/man-pages/man1/make.1.html)
- [Docker](https://www.docker.com/)
- [Consul](https://releases.hashicorp.com/consul/)

## Compatibility

|Software|OSS Version|Enterprise Version|
|:---|:---|:---|
|Terraform|0.13.1 or newer||
|Consul|1.8.3 or newer|1.8.3 or newer|
|Vault|1.5.2.1 or newer|1.5.2.1 or newer|
|Nomad|0.12.3 or newer|0.12.3 or newer|

## Providers
- [Nomad](https://registry.terraform.io/providers/hashicorp/nomad/latest/docs)
- [Vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)

## Usage
The following command will run hive in the [example/standalone-vault-provided-creds](example/standalone-vault-provided-creds) folder.

```sh
make up
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
Check [example/README.md#data-example-upload](example/README.md#data-example-upload)

## Intentions
Module is deployed with [service mesh approach using consul-connect integration](https://www.consul.io/docs/connect), where [communication `service-to-service` controlled by intentions](https://learn.hashicorp.com/tutorials/consul/get-started-service-networking#control-communication-with-intentions).
Intentions are required **`only`** when [consul acl is enabled and default_policy is deny](https://learn.hashicorp.com/tutorials/consul/access-control-setup-production#enable-acls-on-the-agents).

In the examples, intentions are created in the Ansible playboook [00_create_intention.yml](dev/ansible/00_create_intention.yml):

| Intention between | type |
| :---------------- | :--- |
| mc => minio | allow |
| minio-local => minio | allow |
| hive-metastore => postgres | allow |

> :warning: Note that these intentions needs to be created if you are using the module in another module and (consul acl enabled with default policy deny).
>

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
| resource | Resource allocations | object | - | no |
| resource.cpu | Resource allocation - cpu | number | 500 | no |
| resource.memory | Resource allocation - memory | number | 1024 | no |
| resource_proxy | Resource allocations for proxy | object | - | no |
| resource_proxy.cpu | Resource allocation for proxy - cpu | number | 200 | no |
| resource_proxy.memory | Resource allocation for proxy - memory | number | 128 | no |
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

**NB!** current implementation supports only [`hivemetastore`](conf/nomad/hive.hcl#110)

## Examples

Folder [example](example) contains examples of module usage, please refer for more details.

The example-code shows the minimum of what you need do to set up this module.
```hcl
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
    vault_kv_path          = "",
    vault_kv_access_key    = "",
    vault_kv_secret_key    = ""
  }
  access_key = "minio"
  secret_key = "minio123"

  data_dir                        = "/minio/data"
  buckets                         = ["default", "hive"]
  container_environment_variables = ["JUST_EXAMPLE_VAR1=some-value", "ANOTHER_EXAMPLE2=some-other-value"]
  use_host_volume                 = false
  use_canary                      = false

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
  source = "../.."

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
```

## Contributors
[<img src="https://avatars0.githubusercontent.com/u/40291976?s=64&v=4">](https://github.com/fredrikhgrelland)
[<img src="https://avatars2.githubusercontent.com/u/29984156?s=64&v=4">](https://github.com/claesgill)
[<img src="https://avatars3.githubusercontent.com/u/15572799?s=64&v=4">](https://github.com/zhenik)
[<img src="https://avatars3.githubusercontent.com/u/67954397?s=64&v=4">](https://github.com/Neha-Sinha2305)
[<img src="https://avatars3.githubusercontent.com/u/71001093?s=64&v=4">](https://github.com/dangernil)
[<img src="https://avatars1.githubusercontent.com/u/51820995?s=64&v=4">](https://github.com/pdmthorsrud)

## License
This work is licensed under Apache 2 License. See [LICENSE](./LICENSE) for full details.

## References
