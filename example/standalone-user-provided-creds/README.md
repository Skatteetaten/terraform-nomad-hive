# Standalone example with user provided credentials

User provides credentials for `minio` and `postgres` database via input variables of modules. See next section, [modules in use](#modules-in-use).

Hive is deployed as one instance in [hivemetastore mode](../../docker/bin/hivemetastore).
At the startup, Hive will attempt to create the required tables in the Postgres database, and if tables exist, this step will be skipped.

## Modules in use

| Modules | version   |
| ------------- |:-------------:|
| [terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio) | \>= 0.3.0 |
| [terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres) | \>= 0.3.0 |
