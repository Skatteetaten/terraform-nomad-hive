# This is a terraform module examples

All examples have their own directories, with a `main.tf` that references one or more modules.

| Examples |
| :------------- |
| [standalone-user-provided-creds](standalone-user-provided-creds) |
| [standalone-vault-provided-creds](standalone-vault-provided-creds) |

## Data example upload
The [resources/data](resources/data) directory contains a data sample that is uploaded via the [dev/ansible/04_upload_files.yml](../dev/ansible/20_upload_files.yml) playbook.
To create tables and do queries you can use the [beeline cli](https://cwiki.apache.org/confluence/display/Hive/HiveServer2+Clients#HiveServer2Clients-Beeline%E2%80%93CommandLineShell), see the sql-example bellow. However, if you're not familiar with the `beeline-cli`, see the [verifying setup](../README.md#verifying-setup) section.

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

## References
- [Creating Modules - official terraform documentation](https://www.terraform.io/docs/modules/index.html)
