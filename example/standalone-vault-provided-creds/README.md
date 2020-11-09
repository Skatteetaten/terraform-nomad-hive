# Standalone example with vault provided credentials

Before deploy the module, vault K/V store should contain credentials and policies.
In current example, all required actions are automated by ansible.

- [required policy](../../dev/vagrant/bootstrap/vault/post/01-create_vault_policy_to_read_secrets.yml)
- [required credentials](../../dev/ansible/01_generate_secrets_vault.yml)

Vault provides credentials for `minio` and `postgres` database via render them directly into nomad job.

See next section, [modules in use](#modules-in-use).

Hive is deployed as one instance in [hivemetastore mode](../../docker/bin/hivemetastore).
At the startup hive will attempt to create required tables in postgres database, if tables are exist, this step will be skipped.

## Modules in use

| Modules | version   |
| ------------- |:-------------:|
| [terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio) | \>= 0.3.0 |
| [terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres) | \>= 0.3.0 |
