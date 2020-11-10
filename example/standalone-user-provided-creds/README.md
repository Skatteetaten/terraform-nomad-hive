# Standalone example with user provided credentials
This is an example of a standalone Hive that implement user provided credentials for Minio and Postgres via input variables.

Hive is deployed as one instance in [hivemetastore mode](../../docker/bin/hivemetastore).
At the startup, Hive will attempt to create the required tables in the Postgres database, and if tables exist, this step will be skipped.

## Modules in use

| Modules | version   |
| ------------- |:-------------:|
| [terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio) | \>= 0.3.0 |
| [terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres) | \>= 0.3.0 |
