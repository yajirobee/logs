---
layout: memo
title: PostgreSQL cheatsheet
---

# Environment
## Install by apt
follow instruction of [postgres wiki](https://wiki.postgresql.org/wiki/Apt).

```sh
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
sudo sh -c 'echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
apt-cache show postgresql-15
```

**Note: `arch` should be specifed on sources.list.**

## Run on docker container
[PostgreSQL image](https://hub.docker.com/_/postgres)
```sh
docker run --name pg -e POSTGRES_PASSWORD=secret -p 5432:5432 -d postgres:15.3
```

## Attach running container
```sh
docker exec -it pg bash
```
## Flyway for PostgreSQL
- [Flyway >=9.1.2 hanging forever on concurrent index creation](https://github.com/flyway/flyway/issues/3508)

Use `-postgresql.transactional.lock=false` option

# Administration
## Get storage size of relations
- [Disk Usage](https://wiki.postgresql.org/wiki/Disk_Usage)
- [pg_total_relation_size](https://pgpedia.info/p/pg_total_relation_size.html)

# Query execution
## Generic vs custom plans for prepared statement
> By default (that is, when `plan_cache_mode` is set to auto), the server will automatically choose whether to use a generic or custom plan for a prepared statement that has parameters. The current rule for this is that the first five executions are done with custom plans and the average estimated cost of those plans is calculated. Then a generic plan is created and its estimated cost is compared to the average custom-plan cost.

- [SQL Prepare](https://www.postgresql.org/docs/current/sql-prepare.html)
- [GUC plan\_cache\_mode](https://www.postgresql.org/docs/current/runtime-config-query.html#GUC-PLAN-CACHE_MODE)

### `PreparedStatement` of PostgreSQL JDBC
> An internal counter keeps track of how many times the statement has been executed and when it reaches the prepareThreshold (default 5) the driver will switch to creating a named statement and using Prepare and Execute.

- [pgjdbc server prepared statement handling](https://jdbc.postgresql.org/documentation/server-prepare/#server-prepared-statements)

## Portal (cursor)
- [Extented query protocol](https://www.postgresql.org/docs/current/protocol-flow.html#PROTOCOL-FLOW-EXT-QUERY)
- [Guide to PostgreSQL Cursors](https://levelup.gitconnected.com/guide-to-postgresql-cursors-e3524fef8f16)

## Buffer management for large relation scan
For large relation scan, a small ring buffer is used.
- [backend/storage/buffer/README](https://github.com/postgres/postgres/blob/e722846daf4a37797ee39bc8ca3e78a4ef437f51/src/backend/storage/buffer/README#L205-L216)
- [Bulk buffer access strategies](https://github.com/postgres/postgres/blob/e722846daf4a37797ee39bc8ca3e78a4ef437f51/src/include/storage/bufmgr.h#L35-L38)

# DDL
## Locks
- `create index if not exist` takes `SHARE` lock even if the index already exists

confirmed on PostgreSQL 14.9
```
test=# select pg_backend_pid();
 pg_backend_pid
----------------
          20944
(1 row)

test=# begin;
BEGIN
test=*# create index if not exists test_idx on test (key);
NOTICE:  relation "test_idx" already exists, skipping
CREATE INDEX

-- another connection
test=# select pid, relation::regclass, mode, granted, query from pg_locks join pg_stat_activity using (pid) where locktype = 'relation' and pid <> pg_backend_pid() order by query_start;
  pid  | relation |   mode    | granted |                       query
-------+----------+-----------+---------+----------------------------------------------------
 20944 | test     | ShareLock | t       | create index if not exists test_idx on test (key);
(1 row)
```
