---
layout: blog
title: "Study AWS Aurora Serverless V2"
tags: Database AWS
---


<!--end_excerpt-->

# [Pricing](https://aws.amazon.com/rds/aurora/pricing/)
1 Aurora capacity unit (ACU) = approximately 2 gibibytes (GiB) of memory, corresponding CPU, and networking.

In US East region as of Jan. 22, 2024, $0.12 per ACU hour for Aurora Standard.
- $0.12 per vCPU hour
- $0.06 per GiB memory hour

Reference: provisioned on-demand instance

for db.r7g.large (2 vCPU, 16 GiB Memory, up to 12.5 Gbps Network bandwidth), $0.276 per hour
- $0.138 per vCPU hour (115% of serverless)
- $0.017 per GiB memory hour (29% of serverless)

# Notes
## Capacity configuration

From [How Aurora Serverless V2 works](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html):

> We recommend setting the minimum to a value that allows each DB writer or reader to hold the working set of the application in the buffer pool. That way, the contents of the buffer pool aren't discarded during idle periods.

> For example, the amount of memory reserved for the buffer cache increases as a writer or reader scales up, and decreases as it scales down.

From [Considerations for the minimum capacity value](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.min_capacity_considerations):

> The scaling rate for an Aurora Serverless v2 DB instance depends on its current capacity. The higher the current capacity, the faster it can scale up. If you need the DB instance to quickly scale up to a very high capacity, consider setting the minimum capacity to a value where the scaling rate meets your requirement.

## [Scaling](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html)

From [How Aurora Serverless V2 works](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.how-it-works.html):

> Readers in promotion tiers 0 and 1 scale at the same time as the writer. That scaling behavior makes readers in priority tiers 0 and 1 ideal for availability. That's because they are always sized to the right capacity to take over the workload from the writer in case of failover.

> Aurora Serverless v2 scaling can happen while database connections are open, while SQL transactions are in process, while tables are locked, and while temporary tables are in use. Aurora Serverless v2 doesn't wait for a quiet point to begin scaling. Scaling doesn't disrupt any database operations that are underway.


From [When and how scale up happen](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.viewing.monitoring):

## DB parameters

 From [working with parameter groups](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html#aurora-serverless-v2.parameter-groups):

- For Aurora PostgreSQL, Aurora Serverless v2 resizes `shared_buffers` parameter dynamically during scaling.
Aurora Serverless v2 doesn't use any custom parameter values that you specify.
