---
layout: blog
title: "Read papers about DB Feb. 2024"
tags: Database
---

<!--end_excerpt-->

# Parers read in detail
## An Empirical Evaluation of Columnar Storage Formats, PVLDB 2023
[paper](https://www.vldb.org/pvldb/vol17/p148-zeng.pdf)

- Column properties like number of distinct values (NDV), null ration, value range, sortedness vary by data types.
  - NDV is low for integer and string, high for floating point
- Most of columns in the real world skewed
- Parquet and ORC have various parameters on creation. need to clarify conditions for performance evaluation
  - Row group size, Threshold for dictionary encoding, compression scheme
- On their experiments, data files were stored on NVMe SSD local storage of `i3.2xlarge` instance
  - Performance characteristics should totally different for object storages.


## Exploiting Cloud Object Storage for High-Performance Analytics, PVLDB 2023
[paper](Exploiting Cloud Object Storage for High-Performance Analytics)
- Requests in the range of 8-16MB are cost effective in terms of latency, thoughput and cost (EC2 and S3 API cost)
- Bandwitdh of individual requests is similar to HDD
- Request hedging

## Velox: Meta's Unified Execution Engine, PVLDB 2022
[paper](https://vldb.org/pvldb/vol15/p3372-pedreira.pdf)
- Challenge is maintenance of variety of specialized engines
- Execution model must be consistent, e.g. pull / push model, interpreter vs compilation

# Papers browsed
- What's the Difference? Incremental Processing with Change Queries in Snowflake, Proc. ACM Manag. Data 2023
- MotherDuck: DuckDB in the cloud and in the client, CIDR 2024
- Cackle: Analytical Workload Cost and Performance Stability With Elastic Pools, Proc. ACM Manag. Data 2023
- Shared Foundations: Modernizing Meta's Data Lakehouse, CIDR 2023
- NOCAP: Near-Optimal Correlation-Aware Partitioning Joins, Proc. ACM Manag. Data 2023
- Rethink Query Optimization in HTAP Databases, Proc. ACM Manag. Data 2023
- R2D2: Reducing Redundancy and Duplication in Data Lakes, Proc. ACM Manag. Data 2023
- How to Architect a Query Compiler, Revisited, SIGMOD 2018
- Developer's Responsibility or Database's Responsibility? Rethinking Concurrency Control in Databases, CIDR 2023
