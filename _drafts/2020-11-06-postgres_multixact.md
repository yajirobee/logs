---
layout: blog
title: "Study PostgreSQL MultiXacts"
---

I faced a MultiXact (Multiple transactions) ID exhaustion issue recently. 
AFAIK, not so much documentations are available about MultiXacts. 
This is a memo of my study to understand how MultiXacts works.
<!--end_excerpt-->

The error I faced was as follows.

> ERROR: multixact “members” limit exceeded   Detail: This command would create a multixact with 2 members, but the remaining space is only enough for 1 member.
Hint: Execute a database-wide VACUUM in database with OID 16404 with reduced vacuum_multixact_freeze_min_age and vacuum_multixact_freeze_table_age settings.

# What is MultiXact?
- When single transaction locks a tuple
  - Storing locking information in the tuple header[^tupheader]
    - Set the current transaction's XID as its XMAX
    - Set infomask bits to notify the row is locked

- When multiple transactions concurrently lock a tuple
  - Replacing first locker's Xid with a new MultiXactId.
    - MultiXact comprises list of Xids and flag bits to store the strength of each lock

# MultiXact age

VACUUM removes old MultiXacts at the time of tuple freezing.

# References
- [PostgreSQL README of tuplock](https://github.com/postgres/postgres/blob/master/src/backend/access/heap/README.tuplock)
- [Multixacts and Wraparound](https://www.postgresql.org/docs/13/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND)
- [pgrowlocks](https://www.postgresql.org/docs/13/pgrowlocks.html)
- [Multixact members limit exceeded on 9.4](https://www.postgresql-archive.org/Multixact-members-limit-exceeded-td5976890.html)

[^tupheader]: [tuple header layout](https://www.postgresql.org/docs/13/storage-page-layout.html#STORAGE-TUPLE-LAYOUT)

# Memo
## check code path
### SQL
```
create database test;

create table test_lock (id int primary key, name text);

# no tuple lock happen
insert into test_lock (1, 'a');

# no tuple lock happen
select * from test_lock;

# tuple lock happen
select * from test_lock for share;
```

### gdb
- `select * from test_lock for share;`

```
(gdb) info b
Num     Type           Disp Enb Address            What
1       breakpoint     keep y   0x000055ce83c91c60 in heap_lock_tuple at heapam.c:3946

Breakpoint 1, heap_lock_tuple (relation=relation@entry=0x7f8d0b166fb8, tuple=tuple@entry=0x55ce860e1b00, cid=cid@entry=0, mode=mode@entry=LockTupleShare,
    wait_policy=wait_policy@entry=LockWaitBlock, follow_updates=follow_updates@entry=true, buffer=0x7fff9be1da1c, tmfd=0x7fff9be1db30) at heapam.c:3946
3946    {
(gdb) bt
#0  heap_lock_tuple (relation=relation@entry=0x7f8d0b166fb8, tuple=tuple@entry=0x55ce860e1b00, cid=cid@entry=0, mode=mode@entry=LockTupleShare,
    wait_policy=wait_policy@entry=LockWaitBlock, follow_updates=follow_updates@entry=true, buffer=0x7fff9be1da1c, tmfd=0x7fff9be1db30) at heapam.c:3946
#1  0x000055ce83c9489d in heapam_tuple_lock (relation=0x7f8d0b166fb8, tid=0x7fff9be1db2a, snapshot=<optimized out>, slot=0x55ce860e1ab0, cid=0, mode=LockTupleShare,
    wait_policy=LockWaitBlock, flags=3 '\003', tmfd=0x7fff9be1db30) at heapam_handler.c:365
#2  0x000055ce83df4b25 in table_tuple_lock (tmfd=<optimized out>, flags=<optimized out>, wait_policy=<optimized out>, mode=<optimized out>, cid=<optimized out>, slot=0x55ce860e1ab0,
    snapshot=<optimized out>, tid=<optimized out>, rel=<optimized out>) at ../../../src/include/access/tableam.h:1336
#3  ExecLockRows (pstate=0x55ce860e0118) at nodeLockRows.c:182
#4  0x000055ce83dd1153 in ExecProcNode (node=0x55ce860e0118) at ../../../src/include/executor/executor.h:248
#5  ExecutePlan (execute_once=<optimized out>, dest=0x55ce8608f9e0, direction=<optimized out>, numberTuples=0, sendTuples=<optimized out>, operation=CMD_SELECT,
    use_parallel_mode=<optimized out>, planstate=0x55ce860e0118, estate=0x55ce860dfe58) at execMain.c:1646
#6  standard_ExecutorRun (queryDesc=0x55ce8609eb78, direction=<optimized out>, count=0, execute_once=<optimized out>) at execMain.c:364
#7  0x000055ce83f29acc in PortalRunSelect (portal=0x55ce86010c48, forward=<optimized out>, count=0, dest=<optimized out>) at pquery.c:912
#8  0x000055ce83f2acbe in PortalRun (portal=portal@entry=0x55ce86010c48, count=count@entry=9223372036854775807, isTopLevel=isTopLevel@entry=true, run_once=run_once@entry=true,
    dest=dest@entry=0x55ce8608f9e0, altdest=altdest@entry=0x55ce8608f9e0, qc=0x7fff9be1dde0) at pquery.c:756
#9  0x000055ce83f26a3c in exec_simple_query (query_string=0x55ce85fad1b8 "select * from test_lock for share;") at postgres.c:1239
#10 0x000055ce83f28622 in PostgresMain (argc=<optimized out>, argv=argv@entry=0x55ce85fd8d10, dbname=<optimized out>, username=<optimized out>) at postgres.c:4315
#11 0x000055ce83eb4b2f in BackendRun (port=0x55ce85fd1690, port=0x55ce85fd1690) at postmaster.c:4536
#12 BackendStartup (port=0x55ce85fd1690) at postmaster.c:4220
#13 ServerLoop () at postmaster.c:1739
#14 0x000055ce83eb5a9b in PostmasterMain (argc=3, argv=<optimized out>) at postmaster.c:1412
#15 0x000055ce83c50b10 in main (argc=3, argv=0x55ce85fa8110) at main.c:210
```

## check xmax values
```
-- process 1
test=# begin;
BEGIN
test=*# select * from test_lock for share;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi | xids  |     modes     |  pids
------------|--------|-------|-------|---------------|---------
 (0,1)      |    507 | f     | {507} | {"For Share"} | {49337}
 (0,2)      |    507 | f     | {507} | {"For Share"} | {49337}
(2 rows)

-- process 2
test=# begin;
BEGIN
test=*# select * from test_lock for share;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |   xids    |     modes     |     pids
------------|--------|-------|-----------|---------------|---------------
 (0,1)      |      5 | t     | {507,508} | {Share,Share} | {49337,49346}
 (0,2)      |      5 | t     | {507,508} | {Share,Share} | {49337,49346}
(2 rows)

-- process 3
test=# begin;
BEGIN
test=*# select * from test_lock for share;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |     xids      |        modes        |        pids
------------|--------|-------|---------------|---------------------|---------------------
 (0,1)      |      6 | t     | {507,508,509} | {Share,Share,Share} | {49337,49346,49400}
 (0,2)      |      6 | t     | {507,508,509} | {Share,Share,Share} | {49337,49346,49400}
(2 rows)

test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  24 |        6
(1 row)

-- process 4
test=# begin;
BEGIN
test=*# select * from test_lock for share;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |       xids        |           modes           |           pids
------------|--------|-------|-------------------|---------------------------|---------------------------
 (0,1)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,49400,49787}
 (0,2)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,49400,49787}
(2 rows)

test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  25 |        7
(1 row)

-- process 4
test=*# abort;
ROLLBACK

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |       xids        |           modes           |         pids
------------|--------|-------|-------------------|---------------------------|-----------------------
 (0,1)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,49400,0}
 (0,2)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,49400,0}
(2 rows)

-- process 3
test=*# commit;
COMMIT

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |       xids        |           modes           |       pids
------------|--------|-------|-------------------|---------------------------|-------------------
 (0,1)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,0,0}
 (0,2)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,0,0}
(2 rows)

test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  25 |        7
(1 row)

-- process 3
test=# begin;
BEGIN
test=*# select * from test_lock for update;

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |       xids        |           modes           |       pids
------------|--------|-------|-------------------|---------------------------|-------------------
 (0,1)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,0,0}
 (0,2)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,49346,0,0}
(2 rows)

test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  25 |        7
(1 row)

-- process 2
test=*# commit;
COMMIT

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi |       xids        |           modes           |     pids
------------|--------|-------|-------------------|---------------------------|---------------
 (0,1)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,0,0,0}
 (0,2)      |      7 | t     | {507,508,509,510} | {Share,Share,Share,Share} | {49337,0,0,0}
(2 rows)

-- process 1
test=*# commit;
COMMIT

-- monitoring process
test=# select * from pgrowlocks('test_lock');
 locked_row | locker | multi | xids  |     modes      |  pids
------------|--------|-------|-------|----------------|---------
 (0,1)      |    511 | f     | {511} | {"For Update"} | {49400}
 (0,2)      |    511 | f     | {511} | {"For Update"} | {49400}
(2 rows)

test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  26 |        7
(1 row)

-- process 3
 id | name
----|------
  1 | a
  2 | b
(2 rows)

test=*# commit;
COMMIT

-- monitoring process
test=# select relname, age(relfrozenxid), mxid_age(relminmxid) from pg_class where relname = 'test_lock';
  relname  | age | mxid_age
-----------|-----|----------
 test_lock |  26 |        7
(1 row)

```

## check pg\_locks view
> Although tuples are a lockable type of object, information about row-level locks is stored on disk, not in memory, and therefore row-level locks normally do not appear in this view. If a process is waiting for a row-level lock, it will usually appear in the view as waiting for the permanent transaction ID of the current holder of that row lock.

(from https://www.postgresql.org/docs/current/view-pg-locks.html)

```
-- process 1
test=# select pg_backend_pid();
 pg_backend_pid
----------------
           5918
(1 row)

test=# select * from test_lock ;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

test=# begin;
BEGIN
test=*# select * from test_lock for update;
 id | name
----|------
  1 | a
  2 | b
(2 rows)

-- monitoring process
test=# select *, relation::regclass from pg_locks where pid <> pg_backend_pid() order by pid, locktype;
   locktype    | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid  |      mode       | granted | fastpath |    relation
---------------|----------|----------|------|-------|------------|---------------|---------|-------|----------|--------------------|------|-----------------|---------|----------|-----------------------------------
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock    | t       | t        | test_lock_pkey
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock    | t       | t        | test_lock
 relation      |    16384 |     3455 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_class_tblspc_relfilenode_index
 relation      |    16384 |     2663 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_class_relname_nsp_index
 relation      |    16384 |     2662 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_class_oid_index
 relation      |    16384 |     2685 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_namespace_oid_index
 relation      |    16384 |     2684 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_namespace_nspname_index
 relation      |    16384 |     2615 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_namespace
 relation      |    16384 |     1259 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock | t       | t        | pg_class
 transactionid |          |          |      |       |            |           503 |         |       |          | 3/6                | 5918 | ExclusiveLock   | t       | f        |
 virtualxid    |          |          |      |       | 3/6        |               |         |       |          | 3/6                | 5918 | ExclusiveLock   | t       | t        |
(11 rows)

-- process 2
test=# select pg_backend_pid();
 pg_backend_pid
----------------
           5921
(1 row)

test=# begin;
BEGIN
test=*# select * from test_lock for update;

-- monitoring process 
test=# select *, relation::regclass from pg_locks where pid <> pg_backend_pid() order by pid, locktype;
   locktype    | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid  |        mode         | granted | fastpath |        relation
---------------|----------|----------|------|-------|------------|---------------|---------|-------|----------|--------------------|------|---------------------|---------|----------|-----------------------------------
 relation      |    16384 |     2684 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_nspname_index
 relation      |    16384 |     1259 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class
 relation      |    16384 |     2615 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock_pkey
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |     3455 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_tblspc_relfilenode_index
 relation      |    16384 |     2663 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_relname_nsp_index
 relation      |    16384 |     2662 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_oid_index
 relation      |    16384 |     2685 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_oid_index
 transactionid |          |          |      |       |            |           503 |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | f        |
 virtualxid    |          |          |      |       | 3/6        |               |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | t        |
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 4/3                | 5921 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 4/3                | 5921 | RowShareLock        | t       | t        | test_lock_pkey
 transactionid |          |          |      |       |            |           503 |         |       |          | 4/3                | 5921 | ShareLock           | f       | f        |
 tuple         |    16384 |    16385 |    0 |     1 |            |               |         |       |          | 4/3                | 5921 | AccessExclusiveLock | t       | f        | test_lock
 virtualxid    |          |          |      |       | 4/3        |               |         |       |          | 4/3                | 5921 | ExclusiveLock       | t       | t        |
(16 rows)

test=# select pg_blocking_pids(5921);
 pg_blocking_pids
------------------
 {5918}
(1 row)

-- process 3
test=# select pg_backend_pid();
 pg_backend_pid
----------------
           5925
(1 row)

test=# begin;
BEGIN
test=*# select * from test_lock for update;

-- monitoring process
test=# select *, relation::regclass from pg_locks where pid <> pg_backend_pid() order by pid, locktype;
   locktype    | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid  |        mode         | granted | fastpath |        relation
---------------|----------|----------|------|-------|------------|---------------|---------|-------|----------|--------------------|------|---------------------|---------|----------|-----------------------------------
 relation      |    16384 |     2663 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_relname_nsp_index
 relation      |    16384 |     1259 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class
 relation      |    16384 |     2615 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace
 relation      |    16384 |     2684 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_nspname_index
 relation      |    16384 |     2685 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_oid_index
 relation      |    16384 |     2662 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_oid_index
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock_pkey
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |     3455 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_tblspc_relfilenode_index
 transactionid |          |          |      |       |            |           503 |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | f        |
 virtualxid    |          |          |      |       | 3/6        |               |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | t        |
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 4/3                | 5921 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 4/3                | 5921 | RowShareLock        | t       | t        | test_lock_pkey
 transactionid |          |          |      |       |            |           503 |         |       |          | 4/3                | 5921 | ShareLock           | f       | f        |
 tuple         |    16384 |    16385 |    0 |     1 |            |               |         |       |          | 4/3                | 5921 | AccessExclusiveLock | t       | f        | test_lock
 virtualxid    |          |          |      |       | 4/3        |               |         |       |          | 4/3                | 5921 | ExclusiveLock       | t       | t        |
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 5/3                | 5925 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 5/3                | 5925 | RowShareLock        | t       | t        | test_lock_pkey
 tuple         |    16384 |    16385 |    0 |     1 |            |               |         |       |          | 5/3                | 5925 | AccessExclusiveLock | f       | f        | test_lock
 virtualxid    |          |          |      |       | 5/3        |               |         |       |          | 5/3                | 5925 | ExclusiveLock       | t       | t        |
(20 rows)

test=# select pg_blocking_pids(5921);
 pg_blocking_pids
------------------
 {5918}
(1 row)

test=# select pg_blocking_pids(5925);
 pg_blocking_pids
------------------
 {5921}
(1 row)

-- process 2
^CCancel request sent
ERROR:  canceling statement due to user request
CONTEXT:  while locking tuple (0,1) in relation "test_lock"

-- monitoring process
test=# select *, relation::regclass from pg_locks where pid <> pg_backend_pid() order by pid, locktype;
   locktype    | database | relation | page | tuple | virtualxid | transactionid | classid | objid | objsubid | virtualtransaction | pid  |        mode         | granted | fastpath |        relation
---------------|----------|----------|------|-------|------------|---------------|---------|-------|----------|--------------------|------|---------------------|---------|----------|-----------------------------------
 relation      |    16384 |     2684 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_nspname_index
 relation      |    16384 |     1259 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class
 relation      |    16384 |     2615 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock_pkey
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 3/6                | 5918 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |     3455 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_tblspc_relfilenode_index
 relation      |    16384 |     2663 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_relname_nsp_index
 relation      |    16384 |     2662 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_class_oid_index
 relation      |    16384 |     2685 |      |       |            |               |         |       |          | 3/6                | 5918 | AccessShareLock     | t       | t        | pg_namespace_oid_index
 transactionid |          |          |      |       |            |           503 |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | f        |
 virtualxid    |          |          |      |       | 3/6        |               |         |       |          | 3/6                | 5918 | ExclusiveLock       | t       | t        |
 relation      |    16384 |    16385 |      |       |            |               |         |       |          | 5/3                | 5925 | RowShareLock        | t       | t        | test_lock
 relation      |    16384 |    16391 |      |       |            |               |         |       |          | 5/3                | 5925 | RowShareLock        | t       | t        | test_lock_pkey
 transactionid |          |          |      |       |            |           503 |         |       |          | 5/3                | 5925 | ShareLock           | f       | f        |
 tuple         |    16384 |    16385 |    0 |     1 |            |               |         |       |          | 5/3                | 5925 | AccessExclusiveLock | t       | f        | test_lock
 virtualxid    |          |          |      |       | 5/3        |               |         |       |          | 5/3                | 5925 | ExclusiveLock       | t       | t        |
(16 rows)

test=# select pg_blocking_pids(5925);
 pg_blocking_pids
------------------
 {5918}
(1 row)
```
