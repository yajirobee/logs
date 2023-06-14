---
layout: blog
title: "Rethink scale up for analytical DBs"
tags: Database
---

I came across a blog post [BIG DATA IS DEAD](https://motherduck.com/blog/big-data-is-dead/)
that describes how big data processing is rare in the real world.
It was written by a guy from [MotherDuck](https://motherduck.com/) which does business with [DuckDB](https://duckdb.org/).
I suppose his opinion is biased due to his position, but I agreed with most of the arguments.
Ten years ago, scale out based architecture was reasonable for data analysis platform,
but today, scale up seems better choice than scale out for most of use cases.
<!--end_excerpt-->

# Do we still need multiple servers to process one analysis query?
The highlight of the blog is this argument:

> In 2004, when the Google MapReduce paper was written, it would have been very common for a data workload to not fit on a single commodity machine. Scaling up was expensive. In 2006, AWS launched EC2, and the only size of instance you could get was a single core and 2 GB of RAM. There were a lot of workloads that wouldn't fit on that machine.
Today, however, a standard instance on AWS uses a physical server with 64 cores and 256 GB of RAM. That's two orders of magnitude more RAM. If you're willing to spend a little bit more for a memory-optimized instance, you can get another two orders of magnitude of RAM. How many workloads need more than 24TB of RAM or 445 CPU cores?

Data sets used for analysis is typically timeline data which accumulates over time.
Total data volume may be larger than available memory size for data sets that have been
accumulated for a long time without pruning old data.
However, most of cases, data analysis is made against recent data.
AWS released EC2 instance type `u-24tb1.112xlarge` (448 vCPUs, 24TB RAM, 100Gbps network) in October, 2022[^ec2_high_mem]. It's expected that most of analysis queries don't require such many cores and large memory.

[^ec2_history] [EC2 Instance History](https://aws.amazon.com/blogs/aws/ec2-instance-history/)
[^ec2_high_mem] [EC2 High Memory instances release](https://aws.amazon.com/about-aws/whats-new/2022/10/ec2-high-memory-instances-18tib-24tib-memory-available-on-demand-savings-plan-purchase-options/)

# Scale up is cheaper and simpler than scale out
Distributed query engines like Trino, Hive enabled to process large data that don't fit on a single server by using multiple servers. Also, the combination of distributed query and separation of compute and compute made it easy to scale out of query engine cluster when more capacity is required as data volume grows over time. These properties are useful when commodity server was not so powerful and sc
On the other hand, distributed query processing greately increased complexity of query engine implementation compared to single node query engine.

- simpler storage hierarchy
- scan sharing
- join algorithm
- no overhead of inter node communication
- better robustness of query execution
  - no partial failure like distributed query
  - no heartbeat for worker nodes
