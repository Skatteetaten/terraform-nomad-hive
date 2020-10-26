# Standalone example
Hive is deployed as one instance in [hivemetastore mode](../../docker/bin/hivemetastore).
At the startup hive will attempt to create required tables in postgres database, if tables are exist, this step will be skipped.

## Modules in use

| Modules | version   |
| ------------- |:-------------:|
| [terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio) | \>= 0.2.0 |
| [terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres) | \>= 0.2.0 |
