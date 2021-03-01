---
layout: memo
title: Declarative partitioning performance
---

check the basic performance of declarative partitioning.

# Setup
## Table
### No partitioning
```sql
create table notpartitioned (id int primary key);
insert into notpartitioned select * from generate_series(0, 1048575);
```

### 64 partition tables
```sql
create table partitioned_64 (id int primary key) partition by range (id);

do $$
  declare
    n_part int = 64;
    head int;
    tail int;
  begin
    for i in 1..n_part loop
      head = (i-1) * (1 << 14);
      tail = i * (1 << 14);
      execute format('
        create table partitioned_%s_%s 
        partition of partitioned_%s 
        for values from (%s) to (%s)',
        n_part,
        i,
        n_part,
        head,
        tail
      );
    end loop;
  end
$$;

insert into partitioned_64 select * from generate_series(0, 1048575);
```

### 2048 partition tables
```sh
create table partitioned_2048 (id int primary key) partition by range (id);

do $$
  declare
    n_part int = 2048;
    head int;
    tail int;
  begin
    for i in 1..n_part loop
      head = (i-1) * (1 << 9);
      tail = i * (1 << 9);
      execute format('
        create table partitioned_%s_%s 
        partition of partitioned_%s 
        for values from (%s) to (%s)',
        n_part,
        i,
        n_part,
        head,
        tail
      );
    end loop;
  end
$$;

insert into partitioned_2048 select * from generate_series(0, 1048575);
```

## Queries
### SELECT
```
explain analyze select * from notpartitioned where id = 1;
explain analyze select * from partitioned_64 where id = 1;
explain analyze select * from partitioned_2048 where id = 1;
```

### DELETE
```
explain analyze delete from notpartitioned where id = 1;
explain analyze delete from partitioned_64 where id = 1;
explain analyze delete from partitioned_2048 where id = 1;
```


## Result
### PostgreSQL 11
used postgresql 11.10

#### SELECT
```
test=# explain analyze select * from notpartitioned where id = 1;
                                                               QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using notpartitioned_pkey on notpartitioned  (cost=0.42..8.44 rows=1 width=4) (actual time=0.425..0.462 rows=1 loops=1)
   Index Cond: (id = 1)
   Heap Fetches: 1
 Planning Time: 0.147 ms
 Execution Time: 0.702 ms
(5 rows)

test=# explain analyze select * from partitioned_64 where id = 1;
                                                                    QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------
 Append  (cost=0.29..8.31 rows=1 width=4) (actual time=0.367..0.406 rows=1 loops=1)
   ->  Index Only Scan using partitioned_64_1_pkey on partitioned_64_1  (cost=0.29..8.30 rows=1 width=4) (actual time=0.354..0.367 rows=1 loops=1)
         Index Cond: (id = 1)
         Heap Fetches: 1
 Planning Time: 43.714 ms
 Execution Time: 0.457 ms
(6 rows)

test=# explain analyze select * from partitioned_2048 where id = 1;
                                                                      QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------------
 Append  (cost=0.27..8.30 rows=1 width=4) (actual time=0.142..0.184 rows=1 loops=1)
   ->  Index Only Scan using partitioned_2048_1_pkey on partitioned_2048_1  (cost=0.27..8.29 rows=1 width=4) (actual time=0.126..0.141 rows=1 loops=1)
         Index Cond: (id = 1)
         Heap Fetches: 1
 Planning Time: 103.703 ms
 Execution Time: 0.463 ms
(6 rows)
```

#### DELETE
```
test=# explain analyze delete from notpartitioned where id = 1;
                                                                QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------
 Delete on notpartitioned  (cost=0.42..8.44 rows=1 width=6) (actual time=0.087..0.120 rows=0 loops=1)
   ->  Index Scan using notpartitioned_pkey on notpartitioned  (cost=0.42..8.44 rows=1 width=6) (actual time=0.042..0.065 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 0.192 ms
 Execution Time: 0.177 ms
(5 rows)

test=# explain analyze delete from partitioned_64 where id = 1;
                                                                  QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------
 Delete on partitioned_64  (cost=0.29..8.30 rows=1 width=6) (actual time=0.060..0.084 rows=0 loops=1)
   Delete on partitioned_64_1
   ->  Index Scan using partitioned_64_1_pkey on partitioned_64_1  (cost=0.29..8.30 rows=1 width=6) (actual time=0.015..0.033 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 10.130 ms
 Execution Time: 0.211 ms
(6 rows)

test=# explain analyze delete from partitioned_2048 where id = 1;
                                                                    QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------
 Delete on partitioned_2048  (cost=0.27..8.29 rows=1 width=6) (actual time=10.121..10.203 rows=0 loops=1)
   Delete on partitioned_2048_1
   ->  Index Scan using partitioned_2048_1_pkey on partitioned_2048_1  (cost=0.27..8.29 rows=1 width=6) (actual time=3.629..3.707 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 2160.383 ms
 Execution Time: 18.220 ms
(6 rows)
```

### PostgreSQL 12
used postgresql 12.5

#### SELECT
```
test=# explain analyze select * from notpartitioned where id = 1;
                                                               QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using notpartitioned_pkey on notpartitioned  (cost=0.42..8.44 rows=1 width=4) (actual time=0.041..0.120 rows=1 loops=1)
   Index Cond: (id = 1)
   Heap Fetches: 1
 Planning Time: 0.117 ms
 Execution Time: 0.249 ms
(5 rows)

test=# explain analyze select * from partitioned_64 where id = 1;
                                                                 QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using partitioned_64_1_pkey on partitioned_64_1  (cost=0.29..8.30 rows=1 width=4) (actual time=0.047..0.085 rows=1 loops=1)
   Index Cond: (id = 1)
   Heap Fetches: 1
 Planning Time: 0.166 ms
 Execution Time: 0.212 ms
(5 rows)

test=# explain analyze select * from partitioned_2048 where id = 1;
                                                                   QUERY PLAN
-------------------------------------------------------------------------------------------------------------------------------------------------
 Index Only Scan using partitioned_2048_1_pkey on partitioned_2048_1  (cost=0.27..8.29 rows=1 width=4) (actual time=0.047..0.085 rows=1 loops=1)
   Index Cond: (id = 1)
   Heap Fetches: 1
 Planning Time: 0.146 ms
 Execution Time: 0.195 ms
(5 rows)
```

#### DELETE
```
test=# explain analyze delete from notpartitioned where id = 1;
                                                                QUERY PLAN
------------------------------------------------------------------------------------------------------------------------------------------
 Delete on notpartitioned  (cost=0.42..8.44 rows=1 width=6) (actual time=0.397..0.438 rows=0 loops=1)
   ->  Index Scan using notpartitioned_pkey on notpartitioned  (cost=0.42..8.44 rows=1 width=6) (actual time=0.033..0.062 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 0.252 ms
 Execution Time: 0.533 ms
(5 rows)

test=# explain analyze delete from partitioned_64 where id = 1;
                                                                  QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------
 Delete on partitioned_64  (cost=0.29..8.30 rows=1 width=6) (actual time=0.092..0.113 rows=0 loops=1)
   Delete on partitioned_64_1
   ->  Index Scan using partitioned_64_1_pkey on partitioned_64_1  (cost=0.29..8.30 rows=1 width=6) (actual time=0.025..0.040 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 0.414 ms
 Execution Time: 0.757 ms
(6 rows)

test=# explain analyze delete from partitioned_2048 where id = 1;
                                                                    QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------------------------------
 Delete on partitioned_2048  (cost=0.27..8.29 rows=1 width=6) (actual time=0.092..0.115 rows=0 loops=1)
   Delete on partitioned_2048_1
   ->  Index Scan using partitioned_2048_1_pkey on partitioned_2048_1  (cost=0.27..8.29 rows=1 width=6) (actual time=0.030..0.046 rows=1 loops=1)
         Index Cond: (id = 1)
 Planning Time: 0.187 ms
 Execution Time: 0.292 ms
(6 rows)
```
