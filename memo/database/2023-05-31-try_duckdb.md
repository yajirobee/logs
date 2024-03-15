---
layout: memo
title: "Try DuckDB"
---

Playing with DuckDB

# Installation
- [DuckDB Installation](https://duckdb.org/docs/installation/)

## Build
Prerequisite: install [cmake](https://cmake.org/)

```sh
CMAKE_BUILD_PARALLEL_LEVEL=6 make
```

# [TPC-H extension](https://duckdb.org/docs/extensions/tpch)
```sql
install 'tpch';
load 'tpch';

call dbgen(sf=1);
```

```sql
pragma show_tables;
|   name   |
|----------|
| customer |
| lineitem |
| nation   |
| orders   |
| part     |
| partsupp |
| region   |
| supplier |
```

```sql
pragma database_size;
-- in memory
| database_name | database_size | block_size | total_blocks | used_blocks | free_blocks | wal_size | memory_usage | memory_limit |
|---------------|---------------|------------|--------------|-------------|-------------|----------|--------------|--------------|
| memory        | 0 bytes       | 0          | 0            | 0           | 0           | 0 bytes  | 1.4GB        | 13.3GB       |
-- file
| database_name | database_size | block_size | total_blocks | used_blocks | free_blocks | wal_size | memory_usage | memory_limit |
|---------------|---------------|------------|--------------|-------------|-------------|----------|--------------|--------------|
| tpch_sf1      | 260.3MB       | 262144     | 993          | 993         | 0           | 0 bytes  | 259.2MB      | 13.3GB       |
```

```sql
describe region;
| column_name | column_type | null | key | default | extra |
|-------------|-------------|------|-----|---------|-------|
| r_regionkey | INTEGER     | NO   |     |         |       |
| r_name      | VARCHAR     | NO   |     |         |       |
| r_comment   | VARCHAR     | NO   |     |         |       |
```

```sql
summarize lineitem;
|   column_name   |  column_type  |     min     |         max         | approx_unique |         avg         |         std         |   q25   |   q50   |   q75   |  count  | null_percentage |
|-----------------|---------------|-------------|---------------------|---------------|---------------------|---------------------|---------|---------|---------|---------|-----------------|
| l_orderkey      | INTEGER       | 1           | 6000000             | 1508227       | 3000279.604204982   | 1732187.8734803302  | 1526218 | 3009234 | 4504205 | 6001215 | 0.0%            |
| l_partkey       | INTEGER       | 1           | 200000              | 202598        | 100017.98932999402  | 57735.69082650548   | 50076   | 99980   | 150179  | 6001215 | 0.0%            |
| l_suppkey       | INTEGER       | 1           | 10000               | 10061         | 5000.602606138924   | 2886.961998730616   | 2500    | 5000    | 7499    | 6001215 | 0.0%            |
| l_linenumber    | INTEGER       | 1           | 7                   | 7             | 3.0005757167506912  | 1.7324314036519408  | 2       | 3       | 4       | 6001215 | 0.0%            |
| l_quantity      | DECIMAL(15,2) | 1.00        | 50.00               | 50            | 25.507967136654827  | 14.426262537016848  | 13      | 25      | 38      | 6001215 | 0.0%            |
| l_extendedprice | DECIMAL(15,2) | 901.00      | 104949.50           | 923139        | 38255.138484656854  | 23300.43871096203   | 18746   | 36718   | 55151   | 6001215 | 0.0%            |
| l_discount      | DECIMAL(15,2) | 0.00        | 0.10                | 11            | 0.04999943011540163 | 0.03161985510812599 | 0       | 0       | 0       | 6001215 | 0.0%            |
| l_tax           | DECIMAL(15,2) | 0.00        | 0.08                | 9             | 0.04001350893110812 | 0.02581655179884276 | 0       | 0       | 0       | 6001215 | 0.0%            |
| l_returnflag    | VARCHAR       | A           | R                   | 3             |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_linestatus    | VARCHAR       | F           | O                   | 2             |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_shipdate      | DATE          | 1992-01-02  | 1998-12-01          | 2516          |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_commitdate    | DATE          | 1992-01-31  | 1998-10-31          | 2460          |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_receiptdate   | DATE          | 1992-01-04  | 1998-12-31          | 2549          |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_shipinstruct  | VARCHAR       | COLLECT COD | TAKE BACK RETURN    | 4             |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_shipmode      | VARCHAR       | AIR         | TRUCK               | 7             |                     |                     |         |         |         | 6001215 | 0.0%            |
| l_comment       | VARCHAR       |  Tiresias   | zzle? furiously iro | 3558599       |                     |                     |         |         |         | 6001215 | 0.0%            |
```

# Postgres Scanner extension
```sql
install postgres;
load postgres;
attach 'postgresql://postgres@localhost/pgbench' as pgbench (type postgres);
```

- [Postgres Import](https://duckdb.org/docs/guides/import/query_postgres)
- [Postgres Scanner](https://duckdb.org/docs/extensions/postgres_scanner)
  - [github](https://github.com/duckdb/postgres_scanner)

# Parquet extension
Parquet extension is built-in.

## Local Parquet files

### [Export](https://duckdb.org/docs/guides/import/parquet_export)
```sql
copy lineitem to 'lineitem.parquet' (format 'parquet');
```

### [Query](https://duckdb.org/docs/guides/import/query_parquet)
```sql
select l_linenumber, count(*) from read_parquet('lineitem.parquet') group by 1;
```

## Parquet files on S3
- [Load AWS credentials from environment variables](https://github.com/duckdb/duckdb/pull/5419)
```sh
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
export AWS_ACCESS_KEY_ID=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${role_name} | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${role_name} | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(curl -s http://169.254.169.254/latest/meta-data/iam/security-credentials/${role_name} | jq -r '.Token')
```

[aws](https://duckdb.org/docs/extensions/aws) extension was introduced by DuckDB `0.9.0`.
Credentials can be loaded as follows:
```
CALL load_aws_credentials();
```

### [Export](https://duckdb.org/docs/guides/import/s3_export)
```sql
copy lineitem to 's3://${bucket}/lineitem.parquet';
```

### [Query](https://duckdb.org/docs/guides/import/s3_import)
```sql
select l_linenumber, count(*) from read_parquet('s3://${bucket}/lineitem.parquet') group by 1;
```

## Links
- [Performance considerations for Parquet](https://duckdb.org/docs/guides/performance/file-formats)

# Tips
## CLI
- default mode of CLI is "duckbox"
```
D .mode
current output mode: duckbox
```

- increase number of rows displayed by duckbox (default = 40)
```
.maxrows 100
```

- SQL timer
```
.timer on
```

- [Read SQL from file](https://duckdb.org/docs/api/cli.html#reading-sql-from-a-file)
```
.read query.sql
```

## Configuration
[Document](https://duckdb.org/docs/sql/configuration.html)

- Set number of threads
```
SET threads TO 1;
```

- [Enable profiling](https://duckdb.org/docs/sql/pragmas#enable_progress_bar-disable_progress_bar-enable_profiling-disable_profiling-profiling_output)
```
PRAGMA enable_profiling='json';
```

### Tuning to avoid out of memory
- OOM in in-memory mode

Query aborts if it consumers memory more than the limit and temporary directory isn't specified. e.g.
```
Error: Out of Memory Error: failed to allocate data of size 2.0MB (13.1GB/13.1GB used)
Database is launched in in-memory mode and no temporary directory is specified.
Unused blocks cannot be offloaded to disk.

Launch the database with a persistent storage back-end
Or set PRAGMA temp_directory='/path/to/tmp.tmp'
```

set temporary directory to avoid OOM
```
D set temp_directory='duckdb_tmp';
```

- Use jemalloc to avoid memory fragmentation  
About [jemalloc extension](https://github.com/duckdb/duckdb/pull/4971)

- Set `memory_limit` conservatively  
Default value is 80% of RAM, but there is edge cases which may consumer memory more than the limit now.

From [PR #6733](https://github.com/duckdb/duckdb/issues/6733#issuecomment-1486353433):
> What happens is that query 21 has a pipeline with more than one join hashtable,
which both need to spill to disk. The join hashtables try not to take up all available memory,
but are not aware of each others memory usage, and therefore take up more memory than
there is available, causing the OOM exception.

`memory_limit` needs to be configured so that entire memory consumption doesn't exceed available memory.

# Links
- [Dot Commands](https://duckdb.org/docs/api/cli#special-commands-dot-commands)
- [duckdb-tutorial](https://github.com/pdet/duckdb-tutorial)
- [Friendly SQL](https://duckdb.org/docs/guides/sql_features/friendly_sql)
