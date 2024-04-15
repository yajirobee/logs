---
layout: blog
title: "Read papers about DB in April 2024"
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
Careful parameter tuning can bring significant performance improvement.

The paper also showed some reasons that Parquet and ORC are not optimial format for cloud object storages.
The optimal format varies depending on the performance characteristics of storage.
Their insights are helpful if you design a new columnar format.

# Exploiting Cloud Object Storage for High-Performance Analytics, PVLDB 2023
[paper](https://www.vldb.org/pvldb/vol16/p2769-durner.pdf)

The focus of this paper is to explore a design of cost and performance optimal analytical query engine
that stores data on cloud object storage.
First, the authors analyzed the performance characteristics of cloud storages of some venders.
And then, they discussed the query engine design optimal to utilize cloud object storage bandwidth.

## Performance characteristics of cloud object storage and ideal I/O size
The authors told that the performan of object storage is like array of HDDs.
> the bandwidth of individual requests is similar to accessing data on an HDD. To saturate network bandwidth, many simultaneous requests are required

This observation matches with S3 internal architecture partially mentioned on [this post](https://www.allthingsdistributed.com/2023/07/building-and-operating-a-pretty-big-storage-system.html).

It explains the first byte latency of S3 is similar to that of HDDs.
(The latency of HDD is about 1-10 milliseconds. S3 has some overhead to process REST API.)

When the I/O size is small, the first byte latency dominates total request time, i.e. round trip latency bounds the performance.
Their experiments showed that I/O size 8-16MB is required to reach the bandwidth limit per request.
This aligns with [the best practice](https://docs.aws.amazon.com/AmazonS3/latest/userguide/optimizing-performance-guidelines.html#optimizing-performance-guidelines-get-range) suggested by AWS.
Using 8-16MB range size for a single request and parallelizing requests is the best way to saturate network bandwidth efficiently.

### Tail latency and request hedging
It is recommended to restart unresponsive requests. It seems long tail latency is a common issue of cloud object storage.

> Hedging against slow responses. Missing or slow responses from storage servers are a challenge for users of cloud object stores. In our latency experiments, we see requests that have a considerable tail latency. Some requests get lost without any notice. To mitigate these issues, cloud vendors suggest restarting unresponsive requests, known as request hedging. For example, the typical 16 MiB request duration is below 600ms for AWS. However, less than 5% of objects are not downloaded after 600ms. Missing responses can also be found by checking the ﬁrst byte latency. Similarly to the duration, less than 5% have a ﬁrst byte latency above 200ms. Hedging these requests does not introduce signiﬁcant cost overhead

## Balance of retrieval and processing performance
Although request concurrency is required to saturage network bandwidth, the load to make requests shouldn't be
too much not to hinder query processing. When a bottleneck is throughput of processing data rather than downloading
data from S3, more compute resources should be assigned for query processing.
A challenge is the load to process data depends on input data and query. It means optimal resource allocation for
downloading and processing varies by input data and query.

The approach of the paper is to adaptively adjust number of threads to download and process data while query execution.

> a huge download task with hundreds of threads could make the DBMS unresponsive to newly arriving queries since the DBMS has no control over the retrieval threads. Furthermore, the mix of downloading and processing threads is hard to balance, especially with this vast number of concurrently active threads.

> A key challenge is how to balance query processing and downloading. Without enough retrieval threads, the network bandwidth limit can not be reached. On the other hand, if we use too few worker threads for computation-intensive queries, we lose the in-memory computation performance of our DBMS

> The main goal of the object scheduler is to strike a balance between processing and retrieval performance. It assigns diﬀerent jobs to the available worker threads to achieve this balance. If the retrieval performance is lower than the scan performance, it increases the amount of retrieval and preparation threads. On the other hand, reducing the number of retrieval threads results in higher processing throughput

## Summary
The observations of cloud object storage performance evaluation are interesting.
It is worth reading if you run data intensive applications on cloud object storage.

Also, the problem to balance the load between downloading and processing data isn't trivial.
It definitely needs to be addressed to maximize resource utilization of analytical query engines.

# Velox: Meta's Unified Execution Engine, PVLDB 2022
[paper](https://vldb.org/pvldb/vol15/p3372-pedreira.pdf)

Velox is a database acceleration library that provides reusable data processing components.
It is already integrated or being integrated with various data processing systems at Meta like
query engines (Presto, Spark), streaming processing, data ingestion, ML, message bus, etc.

What Meta is trying to solve by Velox is somehow common for data processing engines.

> The fast proliferation of specialized data computation engines targeted to very specific types of workloads has created a siloed data ecosystem. These engines usually share little to nothing with each other and are hard to maintain, evolve, and optimize, and ultimately provide an inconsistent experience to data users.

> this fragmentation ultimately impacts the productivity of data users, who are commonly required to interact with several different engines to finish a particular task. The available data types, functions, and aggregates vary across these systems, and the behavior of those functions, null handling, and casting can be vastly inconsistent across engines

> All engines need a type system to represent scalar and complex data types, an in memory representation of these (often columnar) datasets, an expression evaluation system, operators (such as joins, aggregation, and sort), in addition to storage and network serialization, encoding formats, and resource management primitives.

These arguments seem legitimate for me. I also need to remember semantics of some engines in my daily work,
e.g. PostgreSQL vs MySQL, Trino vs Hive.
It increases cognitive load significantly when I need to interact with multiple different engines.
Consistent semantics improve productivity of users for sure.

It's also likely to be helpful for engine developers especially when engines are maintained in the same people or organization.
On the other hand, however, there should also be some pitfalls due to the nature of libraries, e.g.
- Difference of development lifecycle between the library and engines
  - It may be difficult to fix a critical bug observed on an engine caused by the library in a timely manner.
- Surprising behavior change of engines because of a trivial change of library
  - It's often the case that a small change results in significant behavior change in complex systems like data processing engines.
  - The velocity of library development will be slow if the development team were to be too conservative.
- Dependencies broght by the library
  - If an engine required only few functionalities of the library, it may be overkill to use it. It should be an option towrite from scratch to avoid dependency hell.

Anyway, I think it's good that there is an option to share common implementations.
Ideally, each engine developer can decide whether they use a library or write from scratch depending on trade-off.
This is a case study how the code of data processing engines can be shared.

# Papers browsed
(This is just a personal reminder.)

- What's the Difference? Incremental Processing with Change Queries in Snowflake, Proc. ACM Manag. Data 2023
- MotherDuck: DuckDB in the cloud and in the client, CIDR 2024
- Cackle: Analytical Workload Cost and Performance Stability With Elastic Pools, Proc. ACM Manag. Data 2023
- Shared Foundations: Modernizing Meta's Data Lakehouse, CIDR 2023
- NOCAP: Near-Optimal Correlation-Aware Partitioning Joins, Proc. ACM Manag. Data 2023
- Rethink Query Optimization in HTAP Databases, Proc. ACM Manag. Data 2023
- R2D2: Reducing Redundancy and Duplication in Data Lakes, Proc. ACM Manag. Data 2023
- How to Architect a Query Compiler, Revisited, SIGMOD 2018
- Developer's Responsibility or Database's Responsibility? Rethinking Concurrency Control in Databases, CIDR 2023
