---
layout: blog
title: "Rethink scale up for analytical DBs"
tags: Database
---

I came across a blog post [BIG DATA IS DEAD](https://motherduck.com/blog/big-data-is-dead/)
that describes how big data processing is rare in the real world. Storing very large data became common for sure,
but it's still uncommon to process all stored data in a single analytic query.
It was written by a guy from [MotherDuck](https://motherduck.com/) which does business with [DuckDB](https://duckdb.org/).
I suppose his opinion is biased due to his position, but I agreed with most of the arguments.

Ten years ago, scale out based architecture was reasonable for data analysis platform, but today, scale up seems a better choice than scale out to process a query that retrieve large data in most cases.
<!--end_excerpt-->

# Do we still need multiple servers to process one analysis query?
The highlight of the blog is this argument:

> In 2004, when the Google MapReduce paper was written, it would have been very common for a data workload to not fit on a single commodity machine. Scaling up was expensive. In 2006, AWS launched EC2, and the only size of instance you could get was a single core and 2 GB of RAM[^ec2_history]. There were a lot of workloads that wouldn't fit on that machine.
Today, however, a standard instance on AWS uses a physical server with 64 cores and 256 GB of RAM. That's two orders of magnitude more RAM. If you're willing to spend a little bit more for a memory-optimized instance, you can get another two orders of magnitude of RAM. How many workloads need more than 24TB of RAM or 445 CPU cores?

Large data sets used for analysis is typically timeline data which accumulates over time. Total data volume may be larger than available memory size for data sets that have been accumulated for a long time without pruning old data. However, data analysis is typically made against recent data. Data used by an analysis query are mostly only a small fragment of data set.

AWS released EC2 instance type `u-24tb1.112xlarge` (448 vCPUs, 24TB RAM, 100Gbps network) in October, 2022[^ec2_high_mem]. It's expected that most of analysis queries don't require such many cores and large memory.

[^ec2_history] [EC2 Instance History](https://aws.amazon.com/blogs/aws/ec2-instance-history/)
[^ec2_high_mem] [EC2 High Memory instances release](https://aws.amazon.com/about-aws/whats-new/2022/10/ec2-high-memory-instances-18tib-24tib-memory-available-on-demand-savings-plan-purchase-options/)

# Scale up is simpler and more performant than scale out
Distributed query engines like Trino, Hive enabled to process large data that don't fit on a single server by using multiple servers. Also, the combination of distributed query and separation of compute and storage allowed easy scale out of query engine cluster when more capacity is required as data volume grows over time. These properties are useful when commodity server was not so powerful and scale up was expensive.

On the other hand, distributed query greatly increased complexity of query engine implementation compared to query processed by single server (let me call it simply "single server query" below as an antonym of "distributed query"). Examples of complexities of distributed query engines are as follows:

## Data locality and load balancing across servers
Distibuted query has one more storage stack compared to single server query, i.e. network IO across servers.
Volume of network IO significantly impacts overall query execution time because network IO is slower than access for memory and locally attached flash storages. Executor of distributed query need to care data locality to reduce network IOs.
At the same time, input data should be distributed to executor threads (or processes) so that all threads constantly work concurrently. Even if we have many executor threads, a query doesn't finish quickly if only single thread was busy and the others were idle. We need to see the balance of data locality and load balancing across servers to process a query faster. It is the complexity brought by distributed query.
Data locality and load balancing are general problem of query executor, but the complexity of the problem varies depending on storage hierarchy. Implementation can be much simplified with simpler storage hierarchy.

## Tolerance for partial failure
In distributed queries, a failure of a server causes failure of entire query if there is no fault tolerance mechanism.
If you used 10 servers to process an analytic query, the probability of seeing failure is higher than when you used 1 server. It means query fails in higher probability on distributed query.
Some distributed query engines have a mechanism to detect and recover from partial failure, e.g. heartbeat of executor servers, reassign of parts of query processing. These also increase complexity of query engine implementation.

## Distributed debugging & profiling
Debugging and profiling of distributed system is generally difficult problem. Distributed query is no exception.


These complexity doesn't exist on single server query. If we don't use distributed query, the maintenance and operation of query engines will be simpler and we can expect better performance because expensive network IO isn't required.

# Example of single server analytical query engines

## DuckDB

# TODO
- check how to parallelize operators
- check join algorithm of duckdb
- scan parallelism
