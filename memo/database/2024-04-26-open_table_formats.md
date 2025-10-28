---
layout: memo
title: Open table formats
---

# Delta Lake
[Protocol](https://github.com/delta-io/delta/blob/master/PROTOCOL.md)

## Integrations / ecosystem
- [List of integrations](https://delta.io/integrations/)
- [Trino](https://trino.io/docs/current/connector/delta-lake.html)
- [DuckDB](https://duckdb.org/docs/extensions/delta)

## Observations / thoughts / questions
- Atomic log record insertion depends on atomic "put if absent" or rename operations
  - To use Delta Lake on S3, transaction coordinator service is required because of lack of them on S3.
  - P.S. Since Aug 20, 2024, S3 supports put if absent. [S3 conditional writes](https://aws.amazon.com/about-aws/whats-new/2024/08/amazon-s3-conditional-writes/)
- Checkpoint is made at the end of write transactions.
  - Checkpoint happens every 10 transactions by default.
- Reference: [Delta Lake: High-Performance ACID Table Storage over Cloud Object Stores, VLDB 2020](https://www.vldb.org/pvldb/vol13/p3411-armbrust.pdf)
- [Row Tracking and Row IDs](https://github.com/delta-io/delta/blob/master/PROTOCOL.md#row-tracking)
  - every row has two Row IDs, fresh Row ID and stable Row ID
  - Default generated Row IDs: calculated by `baseRowId` field of `add` and `remove` actions and row position
  - Materialized Row IDs: stored in a column in the data files
  - fresh Row ID = Default generated Row ID
  - stable Row ID = Materialiezed Row ID if not null, otherwise Default generated Row ID
- [Data skipping](https://docs.databricks.com/en/delta/data-skipping.html)
  - By default, statistics of the first 32 columns are collected

# Links
- [Delta Kernel](https://github.com/delta-io/delta/tree/master/kernel)

---
# Iceberg
**Update June 4th, 2024: [Databricks acquired Tablular](https://www.databricks.com/company/newsroom/press-releases/databricks-agrees-acquire-tabular-company-founded-original-creators). Delta Lake and Iceberg will probably be merged gradually in the near future.**

[Spec](https://iceberg.apache.org/spec/)

## Integrations / ecosystem
- [Trino](https://trino.io/docs/current/connector/iceberg.html)
  - [Query S3 Tables from Trino using Iceberg REST endpoint](https://aws.amazon.com/blogs/storage/query-amazon-s3-tables-from-open-source-trino-using-apache-iceberg-rest-endpoint/)
- [Hive](https://iceberg.apache.org/docs/latest/hive/#partitioned-tables)
- [DuckDB](https://duckdb.org/docs/extensions/iceberg)
  - read only as of 2024/08/07
- [ClickHouse](https://clickhouse.com/docs/en/engines/table-engines/integrations/iceberg)

## Observations / thoughts / questions
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

### Maintenance
- [Maintenance](https://iceberg.apache.org/docs/nightly/maintenance/)

### Partitioning
- [Partitioning](https://iceberg.apache.org/docs/latest/partitioning/)
- [Partition Transforms](https://iceberg.apache.org/spec/#partitioning)

### Importing exsiting parquet files
Iceberg Java API has [AppendFiles API](https://iceberg.apache.org/javadoc/1.9.2/org/apache/iceberg/AppendFiles.html)
that imports existing parquet files to an Iceberg table without rewriting them.
[PyIceberg](https://py.iceberg.apache.org/api/#add-files) and [Spark](https://iceberg.apache.org/docs/latest/spark-procedures/#add_files)
supports `add_files` operation that scans footer of parquet files and imports to a table.

Columns in Iceberg data files are selected by field id. Field IDs of Iceberg schema and
data files schema must match.
- [Column projection](https://iceberg.apache.org/spec/#column-projection)

---
# Hudi
[Spec](https://hudi.apache.org/tech-specs/)

## Integrations / ecosystem
- [Ecosystem support](https://hudi.apache.org/ecosystem/)
- [Trino](https://trino.io/docs/current/connector/hudi.html)

## Observations / thoughts / questions
- It seems Hudi is optimized for near-realtime scan and ingest use cases rather than batch processing.
  - Development seems the most active for Spark, Flink.
  - Trino and Hive support only read as of Aug. 2024.
- Supports both copy-on-write and merge-on-read table types
  - merge-on-read table is optimized for update and delete heavy workload
    - File group of merge-on-read table comprises of columnar base files and [row based delta log files](https://hudi.apache.org/tech-specs/#log-file-format)
  - [Table and query types](https://hudi.apache.org/docs/table_types/)
- File locations are stored on files index on [metadata table](https://hudi.apache.org/docs/metadata)
  - Eliminate expensive list files operation of DFS/cloud object storage
- Hudi supports [Record level index](https://hudi.apache.org/blog/2023/11/01/record-level-index/)
  - Implemented by HFile format which has B+-tree like structures
  - Index is built for a primary key, i.e. keys must be unique across all partitions within a table

### Concurrency Control
> Hudi implements a file level, log based concurrency control protocol on the Hudi timeline, which in-turn relies on bare minimum atomic puts to cloud storage.
(from: [Lakehouse Concurrency Control: Are we too optimistic?](https://hudi.apache.org/blog/2021/12/16/lakehouse-concurrency-control-are-we-too-optimistic/))

> Hudi guarantees that the actions performed on the timeline are atomic & timeline consistent based on the instant time. Atomicity is achieved by relying on the atomic puts to the underlying storage to move the write operations through various states in the timeline.
(from: [Timeline](https://hudi.apache.org/docs/timeline))

---
# Kudo
[Schema design](https://kudu.apache.org/docs/schema_design.html)

## Integrations / ecosystem
Tightly integrated with Impala.
Has integration with NiFi and Spark.

- [Trino](https://trino.io/docs/current/connector/kudu.html)

## Observations / thoughts / questions
- Has replication and high availability mechanism by itself.
  - Others rely on reliability of underlying storage, e.g. HDFS, cloud object storage
  - Makes consensus by Raft algorithm
  - It plays some roles of distributed file system rather than simple table format.
- Direction is somehow similar to Hudi. Aims for rear realtime scan and ingest use cases.

---
# Links
- [Big Metadata: When Metadata is Big Data](https://dl.acm.org/doi/10.14778/3476311.3476385)
- [Apache Hudi vs Delta Lake vs Apache Iceberg](https://www.onehouse.ai/blog/apache-hudi-vs-delta-lake-vs-apache-iceberg-lakehouse-feature-comparison)
