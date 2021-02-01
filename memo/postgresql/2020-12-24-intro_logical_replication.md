---
layout: memo
title: Introduction of Logical Replication
---

An Introduction of Logical Replication setup and maintenance.

As of 2020/12/23, I'm based on PostgreSQL 13.

# Setup
A basic setup is creating a publication on a primary DB and creating a subscription on a replica DB. Some preparations are required before creating publications and subscriptions.

## DB parameters
- [Configuration Document](https://www.postgresql.org/docs/13/logical-replication-config.html)
- Logical replication related [PostgreSQL paramters](https://www.postgresql.org/docs/13/runtime-config-replication.html)


### Publisher (Primary) DB
- `wal_level` = ‘logical’
  - Note: This parameter is set by `rds.logical_replication` = 1 on RDS PostgreSQL
  - Restart required to apply
- `max_replication_slots` >= # of subscriptions + some reserve for the table synchronization
  - Restart required to apply
- `max_wal_senders` >= max_replication_slots + others (e.g. # of physical replicas)
  - Restart required to apply
- `wal_sender_timeout` should be increased in case WAL replay takes time on the replica and timeout happens on the primary
- `statement_timeout` should be increased or disabled so that the initial data copy doesn’t timeout
  - You can also set per role configuration if you don’t want to change the global configuration. e.g.
  ```sql
ALTER ROLE ... SET statement_timeout = 0;
Note: These parameters are set by rds.logical_replication = 1 on RDS PostgreSQL
  ```

### Subscriber (Replica) DB
- `max_replication_slots` >= # of subscriptions
  - Restart required to apply
- `max_logical_replication_workers` >= # of subscriptions + some reserve for the table synchronization
  - Restart required to apply
- `max_worker_processes` > max_logical_replication_workers + others (e.g. max_parallel_workers)
  - Restart required to apply
- `max_sync_workers_per_subscription` should be increased if you want to execute table sync in parallel

## DB role
[PostgreSQL doc for role configuration of logical replication](https://www.postgresql.org/docs/13/logical-replication-security.html)

### Publisher DB
#### To create a publication
- The user must have the CREATE privilege in the database
- To create a publication that publishes all tables, i.e. `CREATE PUBLICATION ... FOR ALL TABLES`, the user must be a superuser. ([On RDS, `rds_superuser` instead](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts.General.FeatureSupport.LogicalReplication))
- To add a table to a publication, user must owns the table

#### To connect from a subscriber
- must have the SELECT privilege on a published table 

I recommended to create a dedicated user to connect a publisher from a subscriber.
If you plan to do DB maintenance by use logical replication, e.g. replicating DB by logical replication and switching to a replica, you may want to block traffic to a primary DB before switching to the replica. In such case, you can realize that by disabling DB users except the one used for logical replication.

### Subscriber DB
To create a subscription, the user must be a superuser. (On RDS, `rds_superuser` instead)

## DB Schema
- The published tables must exist on the subscriber
- Columns of a table are also matched by name
- The order of columns in the subscriber table does not need to match that of the publisher
- The data types of the columns do not need to match, as long as the text representation of the data can be converted to the target type
- The target table can have additional columns not provided by the published table
- DDL is not replicated by logical replication
  - So DDL should also be executed on the subscriber. Generally, better to execute on the subscriber first.
- When you add a table to publication, you need to execute `ALTER SUBSCRIPTION ... REFRESH PUBLICATION;` on the subscriber to replicate the new table. Otherwise, replication doesn’t happen for the new table.
  - [reference](https://www.2ndquadrant.com/en/blog/logical-replication-postgresql-10/)
- Sequence data is not replicated  
  Sequences should be synchronized manually when a subscriber DB becomes a new master DB.
  - [reference](https://www.postgresql.org/docs/13/logical-replication-restrictions.html)
- Replication is only possible from base tables to base tables
  - Partition root tables can't be replicated, so it can't be used for table repartitioning.

## Setup Example on RDS
### Publisher DB
```
CREATE ROLE replication_test LOGIN IN ROLE rds_superuser PASSWORD 'secret'; 

-- connect by replication_test
CREATE PUBLICATION pub_test FOR ALL TABLES;
```

### Subscriber DB
```
-- connect by a user granted rds_superuser
CREATE SUBSCRIPTION sub
CONNECTION 'host=primarydb port=5432 user=replication_test dbname=test_db password=secret'
PUBLICATION pub_test;
```

Note: A role should have privileges to update replication destination tables.


# Maintaining logical replication
## DDL
When you execute DDL, in most cases you need to execute it on the replica as well as the primary.

When you create a table and add it to a publication or you use `CREATE PUBLICATION ... FOR ALL TABLES`, you need to execute `ALTER SUBSCRIPTION … REFRESH PUBLICATION` on the replica to start replication on the new table.

## Monitoring
### Publisher DB
- `pg_publication` : list of publications
- `pg_replication_slots` : list of replication slots
  - a logical replication slot is created when a subscription is created unless create_slot = false is specified.
  - Temporary replication slots are created up to max_sync_workers_per_subscription when table sync workers are running.
- `pg_stat_replication` : statistics of replications
  - table sync worker connections also appear
  - Replication lag, i.e. remaining amount of data for the replica to catch up with the primary, can be measured as LSN gap. e.g.
  ```
select pg_current_wal_lsn() - replay_lsn lsn_lag from pg_stat_replication;
  ```
    - If the lag keeps increasing, amount of updates on the primary is too much and the replica can’t catch up. You may need to multiplexing replication connections described on the next section.
- When asynchronous replication is used, `replay_lag` shows time elapsed between flushing WAL on the primary and receiving notification that the standby server has written, flushed and applied it. https://www.postgresql.org/docs/13/monitoring-stats.html#PG-STAT-REPLICATION-VIEW
  - When a large transaction is committed, `replay_lag` may increase.
- `pg_stat_activity`

### Subscriber DB
- `pg_subscription` : list of subscriptions
- `pg_stat_subscription` : statistics of subscriptions

## Multiplexing replication connections
Replicating all tables by a publication, i.e. `CREATE PUBLICATION … FOR ALL TABLES` , is a good start point for the first trial. However, if the primary DB has many updates that the replication worker can’t handle by single process, you need to split publications with corresponding subscriptions to parallelize replay of updates.  
Note that on logical replication, WALs are sent to the replica when a transaction is committed. It means if there are transactions that has many updates, they will cause large WALs to replay on the replica and could be a cause of replication delay increase.

If you have 2 tables that have many updates, they should be assigned different publications. e.g. given `tbl_1` and `tbl_2` have many updates, you should create 2 publications like `CREATE PUBLICATION pub_1 FOR tbl_1` and `CREATE PUBLICATION pub_2 FOR tbl_2`. 

If a table has significant updates, partitioning the table and assigning different publications for partition tables can be an option.

# Trouble shooting
## A subscription cannot be dropped when a publication is not reachable
disable subscription and disassociate publication, then you can drop a subscription

```
test_db=> drop subscription sub_test ;
ERROR:  could not drop the replication slot "sub_test" on publisher
DETAIL:  The error was: ERROR:  replication slot "sub_test" does not exist

test_db=> alter subscription sub_test disable;
ALTER SUBSCRIPTION
test_db=> alter subscription sub_test set (slot_name = NONE);
ALTER SUBSCRIPTION
test_db=> drop subscription sub_test ;
DROP SUBSCRIPTION
```

## Table sync worker failed in the initial data copy due to statement timeout
Error example

```
2021-01-18 09:07:20 UTC::@:[18426]:ERROR:  could not receive data from WAL stream: ERROR:  canceling statement due to statement timeout
2021-01-18 09:07:20 UTC::@:[18426]:CONTEXT:  COPY test, line 2182054
2021-01-18 09:07:20 UTC::@:[7831]:LOG:  background worker "logical replication worker" (PID 18426) exited with exit code 1
```
A: increase or disable (set 0) statement_timeout. 
COPY statement is used for the initial data copy and it takes long time for a large table.

## WAL sender process terminated due to replication timeout
Error example
```
2021-01-25 02:17:23 UTC:54.243.203.218(31507):replication_test@testdb:[45580]:LOG:  terminating walsender process due to replication timeout
2021-01-25 02:17:23 UTC:54.243.203.218(31507):replication_test@testdb:[45580]:CONTEXT:  slot "sub_test", output plugin "pgoutput", in the change callback, associated LSN 57406/F6EB8570
```

A: increase wal_sender_timeout. [similar issue](https://www.postgresql-archive.org/terminating-walsender-process-due-to-replication-timeout-td6086232.html)

# Observations
## Replication apply worker is likely to be a bottleneck.
It’s better to split publications and subscriptions to parallelize replication apply for tables that have heavy traffic.

## Logical replication slots must be dropped before in-place major version upgrade of a RDS instance
```
------------------------------------------------------------------
Upgrade could not be run on Tue Jan 19 03:06:06 2021
------------------------------------------------------------------
The instance could not be upgraded from 11.1.R1 to 12.4.R1 because of following reasons. Please take appropriate action on databases that have usages incompatible with requested major engine version upgrade and try again.
- Following usages in database 'testdb' need to be corrected before upgrade:
-- The instance could not be upgraded because one or more databases have logical replication slots. Please drop all logical replication slots and try again.

```

# References
- [introduction of logical replication](https://www.postgresql.org/docs/13/logical-replication.html)
- [create publication](https://www.postgresql.org/docs/13/sql-createpublication.html)
- [replication related parameters](https://www.postgresql.org/docs/13/runtime-config-replication.html)
- [introduction of logical replication on RDS for PostgreSQL](https://aws.amazon.com/blogs/database/using-logical-replication-to-replicate-managed-amazon-rds-for-postgresql-and-amazon-aurora-to-self-managed-postgresql/)
