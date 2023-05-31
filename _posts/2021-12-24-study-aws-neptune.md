---
layout: blog
title: "Study Note of AWS Neptune"
tags: Database
---

[AWS Neptune](https://docs.aws.amazon.com/neptune/latest/userguide/intro.html) is managed graph database service that supports graph query languages [Apache TinkerPop Gremlin](https://tinkerpop.apache.org/docs/current/) and [W3C's SPARQL](https://en.wikipedia.org/wiki/SPARQL).
This post is my study note to understand what is Neptune.

<!--end_excerpt-->

Neptune is based on [Blazegraph](https://blazegraph.com/). 
The first GA release of Neptune was [June 2018](https://docs.aws.amazon.com/neptune/latest/userguide/engine-releases-1.0.1.0.200233.0.html).

# Resource management
The deployment operation is similar to AWS Aurora.
To create DB, a user creates a DB cluster and DB instances on the cluster.
You need to decide a DB instance class based on your CPU and memory requirements.

The storage architecture of Neptune is very similar to AWS Aurora. (I guess they use a common platform internally.)
Neptune data is stored in a cluster volume which is composed of logical blocks called segments.
The data in each segment is replicated into six copies.
Storage allocation is managed automatically. You don't need to specify PIOPS manually like RDS.

Allocated storage size never shrink during existence of a DB cluster.
> The total space allocated is determined by the storage high water mark, which is the maximum amount allocated to the cluster volume at any time during its existence.

You can find further detail on [Neptune document](https://docs.aws.amazon.com/neptune/latest/userguide/feature-overview-storage.html).

# Pricing
Neptune cost is composed of instances, allocated storage size and IOs, backup storage and data transfer.
This is also similar to AWS Aurora.

As of Dec. 2021, the instance cost of Neptune is 20% higher than the same instance of AWS Aurora.  
e.g. `db.r5.large` in US region: Neptune = $0.348/hour, Aurora = $0.29/hour

# Neptune workbench
AWS provides [graph notebook](https://github.com/aws/graph-notebook) utility tool that can be used
to interact with graph databases using Jupyter Notebook.

Neptune workbench lets you work with your Neptune DB cluster using Jupyter notebooks hosted by Amazon SageMaker,
including the ones that Neptune provides in the graph notebook project.
Some tutorial materials are included in the notebook. They are nice to learn how Neptune works.
