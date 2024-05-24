---
layout: memo
title: Data lake and data formats
---

# Table formats
## Delta Lake
[Protocol](https://github.com/delta-io/delta/blob/master/PROTOCOL.md)

- Atomic log record insertion depends on atomic "put if absent" or rename operations
  - To use Delta Lake on S3, transaction coordinator service is required because of lack of them on S3.
- Checkpoint is made at the end of write transactions.
  - Checkpoint happens every 10 transactions by default.
- Reference: [Delta Lake: High-Performance ACID Table Storage over Cloud Object Stores, VLDB 2020](https://www.vldb.org/pvldb/vol13/p3411-armbrust.pdf)

## Iceberg
[Spec](https://iceberg.apache.org/spec/)

- A manifest list is created for each table snapshot.
- [Puffine file format](https://iceberg.apache.org/puffin-spec/) is a file format for indexes and statistics of a table

### Atomic data commi
from [File System Operations](https://iceberg.apache.org/spec/#file-system-operations)

> Tables do not require rename, except for tables that use atomic rename to implement the commit operation for new metadata files.

from [Metastore Tables](https://iceberg.apache.org/spec/#metastore-tables)
> The atomic swap needed to commit new versions of table metadata

### Delete format
- Position delete file points rows by file location and position
- Equality delete file

- How to confirm that data files pointed by a position delete file still exist?

## Hudi
[Spec](https://hudi.apache.org/tech-specs/)

## Kudo
[Schema design](https://kudu.apache.org/docs/schema_design.html)


# Columnar data format
## Parquet
- [File format](https://parquet.apache.org/docs/file-format/)
- [Thrift definition](https://github.com/apache/parquet-format/blob/master/src/main/thrift/parquet.thrift)
