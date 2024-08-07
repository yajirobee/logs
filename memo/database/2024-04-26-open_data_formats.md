---
layout: memo
title: Open table catalog, table and data formats
---

# Catalog formats
## Unity Catalog
[Github](https://github.com/unitycatalog/unitycatalog)


## Polaris Catalog
[Github](https://github.com/snowflakedb/polaris-catalog)
[Announcement](https://www.snowflake.com/blog/introducing-polaris-catalog/)

# Table formats
## Delta Lake
[Protocol](https://github.com/delta-io/delta/blob/master/PROTOCOL.md)

- Atomic log record insertion depends on atomic "put if absent" or rename operations
  - To use Delta Lake on S3, transaction coordinator service is required because of lack of them on S3.
- Checkpoint is made at the end of write transactions.
  - Checkpoint happens every 10 transactions by default.
- Reference: [Delta Lake: High-Performance ACID Table Storage over Cloud Object Stores, VLDB 2020](https://www.vldb.org/pvldb/vol13/p3411-armbrust.pdf)

### Integrations
- [DuckDB](https://duckdb.org/docs/extensions/delta)

## Iceberg
**Update June 4th, 2024: [Databricks acquired Tablular](https://www.databricks.com/company/newsroom/press-releases/databricks-agrees-acquire-tabular-company-founded-original-creators). Delta Lake and Iceberg will probably be merged gradually in the near future.**

[Spec](https://iceberg.apache.org/spec/)

- A manifest list is created for each table snapshot.
- [Puffine file format](https://iceberg.apache.org/puffin-spec/) is a file format for indexes and statistics of a table

### Atomic data commit
from [File System Operations](https://iceberg.apache.org/spec/#file-system-operations)

> Tables do not require rename, except for tables that use atomic rename to implement the commit operation for new metadata files.

from [Metastore Tables](https://iceberg.apache.org/spec/#metastore-tables)
> The atomic swap needed to commit new versions of table metadata

### Delete format
- Position delete file points rows by file location and position
- Equality delete file

- How to confirm that data files pointed by a position delete file still exist?

### Integrations
- [Trino](https://trino.io/docs/current/connector/iceberg.html)
- [Hive](https://iceberg.apache.org/docs/latest/hive/#partitioned-tables)
- [DuckDB](https://duckdb.org/docs/extensions/iceberg)
  - read only as of 2024/08/07
- [ClickHouse](https://clickhouse.com/docs/en/engines/table-engines/integrations/iceberg)

## Hudi
[Spec](https://hudi.apache.org/tech-specs/)

### Integrations
- [Trino](https://trino.io/docs/current/connector/hudi.html)

## Kudo
[Schema design](https://kudu.apache.org/docs/schema_design.html)

## Links
- [Big Metadata: When Metadata is Big Data](https://dl.acm.org/doi/10.14778/3476311.3476385)

# Columnar data format
## Parquet
- [File format](https://parquet.apache.org/docs/file-format/)
- [Thrift definition](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift)

## Links
- [An Empirical Evaluation of Columnar Storage Formats](https://www.vldb.org/pvldb/vol17/p148-zeng.pdf)
- [Exploiting Cloud Object Storage for High-Performance Analytics](https://www.vldb.org/pvldb/vol16/p2769-durner.pdf)
