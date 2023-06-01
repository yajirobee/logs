---
layout: blog
title: "Max size of IN operator on PostgreSQL"
tags: PostgreSQL
---

[PostgreSQL document](https://www.postgresql.org/docs/12/functions-subquery.html#FUNCTIONS-SUBQUERY-IN)
doesn't mention "IN" operator limit size explicitly.
quickly checking how many elements can be supplied.
<!--end_excerpt-->

I confirmed on PostgreSQL 12.5.

The background process crashed when in clause length had 16 million integers.

```
postgres=# select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<20) t2 (i));
 count
-------
    32
(1 row)

Time: 789.585 ms
postgres=# select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<21) t2 (i));
 count
-------
    32
(1 row)

Time: 1509.212 ms (00:01.509)
postgres=# select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<22) t2 (i));
 count
-------
    32
(1 row)

Time: 3127.256 ms (00:03.127)
postgres=# select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<23) t2 (i));
 count
-------
    32
(1 row)

Time: 6945.673 ms (00:06.946)
postgres=# select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<24) t2 (i));
server closed the connection unexpectedly
        This probably means the server terminated abnormally
        before or while processing the request.
The connection to the server was lost. Attempting reset: Failed.
Time: 9806.864 ms (00:09.807)
```

Execution plan was as follows:
```
postgres=# explain select count(*) from generate_series(1, 1<<5) t1 (i) where i in (select * from generate_series(1, 1<<23) t2 (i));
                                            QUERY PLAN
---------------------------------------------------------------------------------------------------
 Aggregate  (cost=104861.43..104861.44 rows=1 width=8)
   ->  Hash Join  (cost=104858.32..104861.40 rows=16 width=0)
         Hash Cond: (t2.i = t1.i)
         ->  HashAggregate  (cost=104857.60..104859.60 rows=200 width=4)
               Group Key: t2.i
               ->  Function Scan on generate_series t2  (cost=0.00..83886.08 rows=8388608 width=4)
         ->  Hash  (cost=0.32..0.32 rows=32 width=4)
               ->  Function Scan on generate_series t1  (cost=0.00..0.32 rows=32 width=4)
 JIT:
   Functions: 18
   Options: Inlining false, Optimization false, Expressions true, Deforming true
(11 rows)
```
