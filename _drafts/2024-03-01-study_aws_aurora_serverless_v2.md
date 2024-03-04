---
layout: blog
title: "Study AWS Aurora Serverless v2"
tags: Database AWS
---

Amazon launched [Aurora Serverless v2 on Apr 21, 2022](https://aws.amazon.com/about-aws/whats-new/2022/04/amazon-aurora-serverless-v2/).
Aurora Serverless v2 is designed for applications that have variable workloads.
The DB capacity dynamically changes as the workload changes, so we don't need to provision
the capacity to meet the demand of peak load.
I evaluated Aurora Serverless v2 to check actual behaviors and fitness for production applications.

<!--end_excerpt-->

On this post, Aurora Serverless v2 PostgreSQL was used for evaluation.
Note that MySQL compatible edition is out of scope.

# [Pricing](https://aws.amazon.com/rds/aurora/pricing/)
1 Aurora capacity unit (ACU) = approximately 2 gibibytes (GiB) of memory, corresponding CPU, and networking.

In US East region as of Mar. 1, 2024, $0.12 per ACU hour for Aurora Standard.
- $0.12 per vCPU hour
- $0.06 per GiB memory hour

Reference: provisioned on-demand instance

for db.r7g.large (2 vCPU, 16 GiB Memory, up to 12.5 Gbps Network bandwidth), $0.276 per hour
- $0.138 per vCPU hour (115% of serverless)
- $0.017 per GiB memory hour (29% of serverless)

Aurora Serverless v2 has only pricing for on-demand use.
Provisioned instance is more cost efficient if you used reserved instance.

# Considerations for DB instance configurations

## Capacity configuration
Although Aurora Serverless v2 adaptively scale, there are some considerations to avoid a performance cliff
in case of a sudden surge of requests. Particularly, too small minimum capacity is problematic for the following issues.

> We recommend setting the minimum to a value that allows each DB writer or reader to hold the working set of the application in the buffer pool. That way, the contents of the buffer pool aren't discarded during idle periods.

(From [How Aurora Serverless v2 works](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html))

> The scaling rate for an Aurora Serverless v2 DB instance depends on its current capacity. The higher the current capacity, the faster it can scale up. If you need the DB instance to quickly scale up to a very high capacity, consider setting the minimum capacity to a value where the scaling rate meets your requirement.

(From [Considerations for the minimum capacity value](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.min_capacity_considerations))

## DB parameters
There are certain diffences of DB parameters related to DB capacity between provisioned instance and Aurora Serverless v2. I explain only overview here. For further information, please read AWS documentation [working with parameter groups](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.parameter-groups).

- `shared_buffers` parameter is dynamically updated during scaling.
Also, custom parameter values that you specify by DB parameter group is never used.
- For some parameters, e.g. max_connections, when Aurora Serverless v2 evaluates the formula,
it uses the memory size based on the maximum Aurora capacity units (ACUs) for the DB instance, not the current ACU value.

# Managing DB instance

## Scaling
You can find descriptions about how and when scaling events are triggered by Aurora Serverless v2 on the documents.
- [How Aurora Serverless v2 works](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html)
- [When and how scale up happen](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.viewing.monitoring):

I quated some important points as follows.

> Aurora Serverless v2 scaling can happen while database connections are open, while SQL transactions are in process, while tables are locked, and while temporary tables are in use. Aurora Serverless v2 doesn't wait for a quiet point to begin scaling. Scaling doesn't disrupt any database operations that are underway.

### Scaling of reader instances
> Readers in promotion tiers 0 and 1 scale at the same time as the writer. That scaling behavior makes readers in priority tiers 0 and 1 ideal for availability. That's because they are always sized to the right capacity to take over the workload from the writer in case of failover.

# Evaluation
I demonstrated simple benchmarking to evaluate scaling behavior of Aurora Serverless v2.
Especially, the following points were evaluated:
- Timing of scale out / in
  - How fast does scale out happen in case of sudden increase of load?
  - After a surge of load, when does it decide to scale in?
- Is scaling event really seamless?
- How min/max ACU configurations impact scale out/in behavior

## Evaluation environment
I used an Aurora Cluster of PostgreSQL 15.5 that has 1 writer instance of `db.serverless` class, i.e. Serverless v2, in us-east-1 region.
DB parameters were the default values except some logging related ones, e.g. `pg_stat_statement` was enabled.

Min/max capacity was varied as follows to compare scaling behviors.
- min capacity = 1.0, max capacity = 4.0
- min capacity = 1.0, max_capacity = 16.0
- min capacity = 4.0, max_capacity = 16.0

## Benchmark workload
We ran an application that each thread repeats a query that upsert (mostly update) 20 rows.
The workload was changed by varying number of threads from 1 to 16.

## Monitor scaling behavior
- Monitor the following CloudWatch metrics that [AWS document](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.viewing.monitoring) suggested on CloudWatch dashboard
  - `ServerlessDatabaseCapacity`
  - `ACUUtilization`
  - `CPUUtilization`
  - `FreeableMemory`
  - Note that we usually use DataDog for monitoring and these CloudWatch metrics are available too. However, the granularity of metrics is 1 minutes on DataDog even though those metrics are calculated every second. On CloudWatch dashboard, you can see those metrics in 1 second resolution.
- Monitor `shared_buffers` change on PostgreSQL session
  - `shared_buffers` dynamically changes by scale out/in
  - It was monitored like
```psql
postgres=# \x
Expanded display is on.
postgres=# select pg_size_pretty(setting::bigint * 8192) shared_buffers from pg_settings where name = 'shared_buffers';
-[ RECORD 1 ]--+-------
shared_buffers | 128 MB

postgres=# \watch 1
Mon Mar  4 17:01:47 2024 (every 1s)

-[ RECORD 1 ]--+-------
shared_buffers | 128 MB

Mon Mar  4 17:01:48 2024 (every 1s)

-[ RECORD 1 ]--+-------
shared_buffers | 128 MB
...
```

