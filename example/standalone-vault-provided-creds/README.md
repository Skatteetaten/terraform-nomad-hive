# Standalone example with vault provided credentials
This is a standalone example of Hive that implements the Vault provider to store credentials for Minio and Postgres.
Before deploying the module, Vault K/V store should contain credentials and policies.
In this example, all required actions are automated by Ansible. See the following files for details.

- Required policy [01-create_vault_policy_to_read_secrets.yml](../../dev/vagrant/bootstrap/vault/post/01-create_vault_policy_to_read_secrets.yml)
- Required credentials [01_generate_secrets_vault.yml](../../dev/ansible/01_generate_secrets_vault.yml)

Vault provides credentials for Minio and Postgres, and render them directly into the Nomad job.

Hive is deployed as one instance in [hivemetastore mode](../../docker/bin/hivemetastore).
At the startup, Hive will attempt to create the required tables in the Postgres database, and if tables exist, this step will be skipped.

## Modules in use
| Modules | version   |
| ------------- |:-------------:|
| [terraform-nomad-minio](https://github.com/fredrikhgrelland/terraform-nomad-minio) | \>= 0.3.0 |
| [terraform-nomad-postgres](https://github.com/fredrikhgrelland/terraform-nomad-postgres) | \>= 0.3.0 |
