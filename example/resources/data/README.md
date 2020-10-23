# File types
Different file types which are uploaded to stack in current example

## CSV

`NB!` Hive supports csv int types for columns.
You can create a table for `csv` file format using `hive-metastore`.
```sql
CREATE EXTERNAL TABLE iris (sepal_length DECIMAL, sepal_width DECIMAL,
petal_length DECIMAL, petal_width DECIMAL, species STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
LOCATION 's3a://hive/data/csv/'
TBLPROPERTIES ("skip.header.line.count"="1");
```
