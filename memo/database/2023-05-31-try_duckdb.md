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
make -j8
```

# TPC-H extension
```sql
INSTALL 'tpch';
LOAD 'tpch';

CALL dbgen(sf=1);
```

```sql
pragma show_tables;
```

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

```sql
pragma database_size;
```
- in memory
| database_name | database_size | block_size | total_blocks | used_blocks | free_blocks | wal_size | memory_usage | memory_limit |
|---------------|---------------|------------|--------------|-------------|-------------|----------|--------------|--------------|
| memory        | 0 bytes       | 0          | 0            | 0           | 0           | 0 bytes  | 1.4GB        | 13.3GB       |
- file
| database_name | database_size | block_size | total_blocks | used_blocks | free_blocks | wal_size | memory_usage | memory_limit |
|---------------|---------------|------------|--------------|-------------|-------------|----------|--------------|--------------|
| tpch_sf1      | 260.3MB       | 262144     | 993          | 993         | 0           | 0 bytes  | 259.2MB      | 13.3GB       |

```sql
describe region;
```

| column_name | column_type | null | key | default | extra |
|-------------|-------------|------|-----|---------|-------|
| r_regionkey | INTEGER     | NO   |     |         |       |
| r_name      | VARCHAR     | NO   |     |         |       |
| r_comment   | VARCHAR     | NO   |     |         |       |

```sql
summarize lineitem;
```

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

# Postgres Scanner extension
```sql
INSTALL postgres;
LOAD postgres;
```

- [Postgres Import](https://duckdb.org/docs/guides/import/query_postgres)
- [Postgres Scanner](https://duckdb.org/docs/extensions/postgres_scanner)

# Parquet extension
Parquet extension is built-in.

## Local Parquet files

### [Export](https://duckdb.org/docs/guides/import/parquet_export)
```sql
copy lineitem to 'lineitem.parquet' (format parquet);
```

### [Query](https://duckdb.org/docs/guides/import/query_parquet)
```sql
select l_linenumber, count(*) from read_parquet('lineitem.parquet') group by 1;
```

## Parquet files on S3

### [Export](https://duckdb.org/docs/guides/import/s3_export)

### [Query](https://duckdb.org/docs/guides/import/s3_import)

# Note
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

# Links
- [Dot Commands](https://duckdb.org/docs/api/cli#special-commands-dot-commands)
- [duckdb-tutorial](https://github.com/pdet/duckdb-tutorial)