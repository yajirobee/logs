---
layout: blog
title: "Read papers about DB in March 2024"
tags: Database
---

This is a note about papers of analytical DB technologies I enjoyed reading recently.
I summarized highlights of some interesting papers.

<!--end_excerpt-->

# An Empirical Evaluation of Columnar Storage Formats, PVLDB 2023
[paper](https://www.vldb.org/pvldb/vol17/p148-zeng.pdf)

This is a comprehensive analysis on common columnar formats [Parquet](https://parquet.apache.org/docs/file-format/) and [ORC](https://orc.apache.org/specification/ORCv1/).
The authers evaluated these formats for various types of real world data on different storage types.
Both Parquet and ORC were initially released in 2013. The landscape of hardware and compute environment,
e.g. on-premise vs cloud, has changed since they were designed.
It is an interesting question that how those formats can handle data analysis workload efficiently
on modern computing environments.

## Tuning knobs of Parquet and ORC
Parquet and ORC have various parameters on creation.
The perfomance to read and write data significantly changes by the parameters even the same format is used.
When we evaluate formats, the parameters must be clarified for fair comparison.
Example of common parameters are as follows:

- Row group size
- Encoding algorithm
  - Threshold for dictionary encoding
- Compression scheme
- Enabled statistics

## Modeling characteristics of real world data set
Modeling of test data set is important to find general insights from experiments.
Without a model, the insights cannot be adapted for other specific data sets.
On the paper, the authors characterized data sets by the following column properties:
- Number of distinct values (NDV)
- Null ratio
- Value range
- Sortedness

These propertires impact efficiency of encoding and scan methods.
The authors calculated the properties for some publicly available real world data sets.
Some interesting observations are mentioned on the paper.

- > As shown in Figure 5a, over 80% of the integer columns and 60% of the string columns have an NDV ratio smaller than 0.01
  - > This implies that Dictionary Encoding would be beneficial to most of the real-world columns
  - NDV tends to be low for integer and string, high for floating point
- > Most columns in the real world exhibit a skewed value distribution, as shown in Figure 5c. Less than 5% of the columns can be classified as Uniform.

## Performance differencies by storage types
The authors manily ran experiments on local NVMe SSD and EBS which random read is fast (2-3 digits microseconds).
They also mentioned difference of behaviors on cloud object storages like S3 (random read latency is 20-30 milliseconds).
Both Parquet and ORC have metadata scattered locations on a file, e.g. header and footer of file, row groups, column chunks, pages, etc.
It is not good for storage random read is slow. It is the reason Parquet and ORC are suboptimal for cloud object storages.

## Trade off of encoding and compression
Lightweight encoding algorithms like dictionary encoding, Run length encoding, Bitpacking can
reduce storage size and improve scan performance.
However, encoding also adds significant computational overhead.
As storage devices get faster, computation overhead gets more noticeable.
It means no single encoding algorithm can handle all types of data sets and storage.
We need to find a sweet spot of the trade off between I/O cost saving and computational overhaed.

Also, mixing multiple encoding is possibly harmful for the following reason.

> Selecting from multiple encoding algorithms at run time imposes noticeable performance overhead on decoding. Future format designs should be cautious about including encoding algorithms that only excel at specific situations in the decoding critical path.

The authors argued that general purpose block compression, e.g. zstd, snappy, gzip, should not be applied by default
because I/O bandwidth saving justify compression overhead.
It may not be good for performance, but I think storage size reduction is not negligible
for systems that handles very large data (like peta to exabytes).
Cost of storage can be a major challenge for such systems.

## Summary
This paper is a good read to understand factors of columnar file format that impact query performance.
It suggests that the best performance cannot be archived by just applying popular data format with default configurations.
It also be helpful if you design a new columnar format.

# Exploiting Cloud Object Storage for High-Performance Analytics, PVLDB 2023
[paper](https://www.vldb.org/pvldb/vol16/p2769-durner.pdf)

The focus of this paper is to explore a design of cost and performance optimal analytical query engine
with cloud object storage.
First, performance characteristics of cloud storages of some venders were studied in-depth.
And then, the authors discussed the query engine design optimal to utilize cloud object storage bandwidth.

## Performance characteristics of cloud object storage and ideal I/O size
The authors told that the performan of object storage is like array of HDDs.
This observation matches with [a post about S3 internal](https://www.allthingsdistributed.com/2023/07/building-and-operating-a-pretty-big-storage-system.html).

> the bandwidth of individual requests is similar to accessing data on an HDD. To saturate network bandwidth, many simultaneous requests are required

Requests in the range of 8-16MB are cost effective in terms of latency, thoughput and cost (EC2 and S3 API cost).
This aligns with [the best practice](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance-guidelines.html#optimizing-performance-guidelines-get-range) suggested by AWS.

## Request hedging
> Hedging against slow responses. Missing or slow responses from storage servers are a challenge for users of cloud object stores. In our latency experiments, we see requests that have a considerable tail latency. Some requests get lost without any notice. To mitigate these issues, cloud vendors suggest restarting unresponsive requests, known as request hedging [10, 34]. For example, the typical 16 MiB request duration is below 600ms for AWS. However, less than 5% of objects are not downloaded after 600ms. Missing responses can also be found by checking the ﬁrst byte latency. Similarly to the duration, less than 5% have a ﬁrst byte latency above 200ms. Hedging these requests does not introduce signiﬁcant cost overhead

## Balance of retrieval and processing performance
> a huge download task with hundreds of threads could make the DBMS unresponsive to newly arriving queries since the DBMS has no control over the retrieval threads. Furthermore, the mix of downloading and processing threads is hard to balance, especially with this vast number of concurrently active threads.

> A key challenge is how to balance query processing and downloading. Without enough retrieval threads, the network bandwidth limit can not be reached. On the other hand, if we use too few worker threads for computation-intensive queries, we lose the in-memory computation performance of our DBMS

> The main goal of the object scheduler is to strike a balance between processing and retrieval performance. It assigns diﬀerent jobs to the available worker threads to achieve this balance. If the retrieval performance is lower than the scan performance, it increases the amount of retrieval and preparation threads. On the other hand, reducing the number of retrieval threads results in higher processing throughput

# Velox: Meta's Unified Execution Engine, PVLDB 2022
[paper](https://vldb.org/pvldb/vol15/p3372-pedreira.pdf)
- Challenge is maintenance of variety of specialized engines
- Execution model must be consistent, e.g. pull / push model, interpreted vs compiled
- Does the performance improvement come from difference between Java and C++? or maturity of implementation?

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
