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

A query to claculate table size with aggregating partitioned tables into the parent table.
```sql
select
  coalesce(pg_partition_root(c.oid)::text, relname) relname,
  count(relname) n_relations,
  pg_size_pretty(sum(pg_table_size(c.oid))) relsize,
  sum(relpages) relpages,
  sum(reltuples) reltuples
from pg_class c
left join pg_namespace n on (n.oid = c.relnamespace)
where nspname = 'public'
group by coalesce(pg_partition_root(c.oid)::text, relname)
having sum(pg_table_size(c.oid)) > 8192
order by sum(pg_table_size(c.oid)) desc
```

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

### Synchronized scan across multiple queries
- [synchronize_seqscans](https://postgresqlco.nf/doc/en/param/synchronize_seqscans/)

# Index
- [Operator Classes and Operator Families](https://www.postgresql.org/docs/current/indexes-opclass.html)

check operators supported by B-tree
```sql
SELECT
  am.amname AS index_method,
  opf.opfname AS opfamily_name,
  amop.amopopr::regoperator AS opfamily_operator
FROM pg_am am, pg_opfamily opf, pg_amop amop
WHERE opf.opfmethod = am.oid
AND amop.amopfamily = opf.oid
AND am.amname = 'btree'
ORDER BY index_method, opfamily_name, opfamily_operator;
```

## Links
- [postgres not using btree_gist index](https://stackoverflow.com/questions/71788182/postgres-not-using-btree-gist-index)

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

# The Query Rewrite Rule System (views and materialized views)
- [Rules and Privileges](https://www.postgresql.org/docs/current/rules-privileges.html)

## Security invoker view
> By default, access to the underlying base relations referenced in the view is determined by the permissions of the view owner.
If the view has the security_invoker property set to true, access to the underlying base relations is determined by the permissions of the user executing the query, rather than the view owner.
(from: https://www.postgresql.org/docs/current/sql-createview.html)

# Statistics
Since pg 15, statistics are stored on the shared memory. Legacy stats collector has gone.
- Main code
  - [pgstat.c](https://github.com/postgres/postgres/blob/master/src/backend/utils/activity/pgstat.c)
  - [pgstat_shmem.c](https://github.com/postgres/postgres/blob/master/src/backend/utils/activity/pgstat_shmem.c)

# Clients
## Set GUC parameters via libpq connection string
e.g.
```
postgresql://user@localhost:5433/mydb?options=-c%20synchronous_commit%3Doff
```
- [libpq Connection Strings](https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-CONNSTRING)

## JDBC
### JDBC automatically executes begin a transaction if required
BEGIN is called unless `QUERY_SUPPRESS_BEGIN` flag is set. ([code](https://github.com/pgjdbc/pgjdbc/blob/e12bc692d1eaa831457136da441f580bb29e4455/pgjdbc/src/main/java/org/postgresql/core/v3/QueryExecutorImpl.java#L615-L617)).

For example, `QUERY_SUPPRESS_BEGIN` is set [when auto commit is true](https://github.com/pgjdbc/pgjdbc/blob/e12bc692d1eaa831457136da441f580bb29e4455/pgjdbc/src/main/java/org/postgresql/jdbc/PgStatement.java#L459-L461).

# Links
- [POSTGRESQLCO.NF](https://postgresqlco.nf/doc/en/param/)
- [pgbadger](https://github.com/darold/pgbadger)
