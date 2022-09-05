---
layout: memo
title: Logical replication with continuous archiving
---

Idea to skip initial copy of logical replication by using a backup taken by [continuous archiving](https://www.postgresql.org/docs/current/continuous-archiving.html).
The original idea is from [this post](https://tech.instacart.com/creating-a-logical-replica-from-a-snapshot-in-rds-postgres-886d9d2c7343).

# Steps
Note: This is just an idea and not tested yet.

1. create a publication and a replication slot
2. create a backup by continuous archiving (pg_basebackup + WAL archiving)
3. restore the DB by Point-In-Time Recovery
   - check the latest LSN
   - `SELECT pg_current_wal_lsn();`
4. create a subscription without a replication slot
   - With options `copy_data = false, create_slot = false, enabled = false`
5. advance the replication slot to sync with the subscriber
   - `pg_replication_origin_advance`
6. enable the subscription and drain WALs
