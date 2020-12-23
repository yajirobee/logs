---
layout: memo
title: Introduction of Logical Replication
---

introduction of Logical Replication setup and maintenance.

As of 2020/12/23, I'm based on PostgreSQL 13.

# Setup
## DB parameters
https://www.postgresql.org/docs/13/logical-replication-config.html

### Publisher DB
     | parameter name          | value                      |
     |-------------------------|----------------------------|
     | wal\_level_             | logical                    |
     | max\_replication\_slots | >= # of subscription       |
     | max\_wal\_senders       | >= max\_replication\_slots |

Note: These parameters are set by rds.logical_replication = 1 on RDS PostgreSQL

### Subscriber DB
     | parameter name                     | value                                                             |
     |------------------------------------|-------------------------------------------------------------------|
     | max\_replication\_slots            | > 1                                                               |
     | max\_logical\_replication\_workers | >= # of subscription + some reserve for the table synchronization |
     | max\_worker\_processes             | > max\_logical\_replication\_workers                              |

## DB role
https://www.postgresql.org/docs/11/logical-replication-security.html

### Publisher DB
```
CREATE ROLE replication_test LOGIN IN ROLE rds_superuser PASSWORD 'secret'; 

-- connect by replication_test
CREATE PUBLICATION pub_test FOR ALL TABLES;
```

Note: A role should be rds_superuser and have CREATE privilege on the replicating DB.

### Subscriber DB
```
CREATE ROLE replication_test LOGIN IN ROLE rds_superuser PASSWORD 'secret';

-- connect by replication_test
CREATE SUBSCRIPTION sub
CONNECTION 'host=primarydb port=5432 user=replication_test dbname=test_db password=secret'
PUBLICATION pub_test;
```

Note: A role should have privileges to update replication destination tables.


# Monitoring
## Publisher DB
- pg\_publication
- pg\_replication\_slots
- pg\_stat\_replication
- pg\_stat\_activity

## Subscriber DB
- pg\_subscription
- pg\_stat\_subscription

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

# Observations
## Refresh subscription is required to replicate a table created on the publisher DB after CREATE SUBSCRIPTION

Even if a publication is defined with FOR ALL TABLES, a subscriber doesn't learn the creation of a new table automatically.

```
ALTER SUBSCRIPTION sub_test REFRESH PUBLICATION;
```

https://www.2ndquadrant.com/en/blog/logical-replication-postgresql-10/

## Sequence data is not replicated

Sequences should be synchronized manually when a subscriber DB becomes a new master DB.

https://www.postgresql.org/docs/11/logical-replication-restrictions.html

## Replication is only possible from base tables to base tables

Partition root tables can't be replicated, so it can't be used for table repartioning.

# References
- introduction of logical replication : https://www.postgresql.org/docs/13/logical-replication.html
- create publication : https://www.postgresql.org/docs/13/sql-createpublication.html
- replication related parameters : https://www.postgresql.org/docs/13/runtime-config-replication.html
- introduction of logical replication on RDS for PostgreSQL : https://aws.amazon.com/blogs/database/using-logical-replication-to-replicate-managed-amazon-rds-for-postgresql-and-amazon-aurora-to-self-managed-postgresql/
