---
layout: memo
title: Data lake and data formats
---

# Delta Lake
[Protocol](https://github.com/delta-io/delta/blob/master/PROTOCOL.md)

- To use on S3, transaction coordinator service is required because of lack of atomic "put if absent" or rename operations.
- Checkpoint is made at the end of write transactions.
  - Checkpoint happens every 10 transactions by default.
- Reference: [Delta Lake: High-Performance ACID Table Storage over Cloud Object Stores, VLDB 2020](https://www.vldb.org/pvldb/vol13/p3411-armbrust.pdf)

# Iceberg
[Spec](https://iceberg.apache.org/spec/)

# Hudi
[Spec](https://hudi.apache.org/tech-specs/)

# Kudo
[Schema design](https://kudu.apache.org/docs/schema_design.html)
