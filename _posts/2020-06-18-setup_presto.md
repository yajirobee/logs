---
layout: blog
title: "Setup Presto"
---

Continues from [the post of Hive setup]({{ site.baseurl }}{% link _posts/2020-06-11-setup_hive3.md %}).
Setting up Presto on Hive next.
<!--end_excerpt-->

# Goal
Executing queries to data stored on Hive / HDFS by Presto.  
Note: Presto only uses data files and Hive metastore as mentioned on [the document](https://prestosql.io/docs/current/connector/hive.html#overview). Hive's query execution environment isn't used.

# Environment and Software Versions
Hardware and Hive / Hadoop are the same as [the previous post]({{ site.baseurl }}{% link _posts/2020-06-11-setup_hive3.md %}).

```
$ java -version
openjdk version "11.0.7" 2020-04-14
OpenJDK Runtime Environment (build 11.0.7+10-post-Ubuntu-3ubuntu1)
OpenJDK 64-Bit Server VM (build 11.0.7+10-post-Ubuntu-3ubuntu1, mixed mode, sharing)
```
Note java vesion was different from Hive / Hadoop.

- Presto 333 from [PrestoSQL](https://prestosql.io/)
  - Both coordinator and worker were deployed in single server as well as Hive & Hadoop

# Setup Remote Hive Metastore Server
Hive metastore needs to run by [remove configuration](https://cwiki.apache.org/confluence/display/Hive/AdminManual+Metastore+Administration#AdminManualMetastoreAdministration-RemoteMetastoreServer) as Presto communicates.

## Server (remote metastore) side
+ Edit configurations
  - `${HIVE_HOME}/conf/hive-site.xml`
  ```xml
    <property>
        <name>hive.server2.thrift.bind.host</name>
        <value>localhost</value>
    </property>  
  ```
+ Start metastore
```
$ $HIVE_HOME/bin/hive --service metastore
```

## Client (Hiveserver) side
+ Edit configurations
  - `${HIVE_HOME}/conf/hive-site.xml`
  ```xml
    <property>
        <name>hive.metastore.uris</name>
        <value>thrift://localhost:9083</value>
    </property>
  ```
+ Start hiveserver2

# Setup Presto
Follow [deployment steps](https://prestosql.io/docs/current/installation/deployment.html).

+ Get Presto distribution
+ Edit configurations
  - Node Properties (node.properties)
    - Coordinator
    ```
node.environment=dev
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=(some filesystem path)
    ```
    - Worker
    ```
node.environment=dev
node.id=ffffffff-ffff-ffff-ffff-fffffffffff1
node.data-dir=(some filesystem path)
    ```
  - JVM Config (jvm.config)  
    Used the same config for coordinator and worker
  ```
-server
-Xmx8G
-XX:-UseBiasedLocking
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+ExplicitGCInvokesConcurrent
-XX:+ExitOnOutOfMemoryError
-XX:+HeapDumpOnOutOfMemoryError
-XX:ReservedCodeCacheSize=512M
-Djdk.attach.allowAttachSelf=true
-Djdk.nio.maxCachedBufferSize=2000000
  ```
  - Config Properties (config.properties)
    - Coordinator
    ```
coordinator=true
node-scheduler.include-coordinator=false
http-server.http.port=8080
query.max-memory=16GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery-server.enabled=true
discovery.uri=http://localhost:8080
    ```
    - Worker
    ```
coordinator=false
http-server.http.port=8081
query.max-memory=16GB
query.max-memory-per-node=1GB
query.max-total-memory-per-node=2GB
discovery.uri=http://localhost:8080
    ```
  - Catalog Properties (catalog/*.properties)  
    Used the same config for coordinator and worker
    - hive.properties
    ```
connector.name=hive-hadoop2
hive.metastore.url=thrift://localhost:9083 # hive.metastore.port
    ```
+ Launch Presto
```
$PRESTO_HOME/bin/launcher start --etc-dir (coordinator etc dir)
$PRESTO_HOME/bin/launcher start --etc-dir (worker etc dir)
```
  
# Connect to Presto
Used Presto CLI here.
```
$ presto --server localhost:8080 --catalog hive
```

Now you can see tables created by Hive.
```
$ beeline -u jdbc:hive2://localhost:10000
...
0: jdbc:hive2://localhost:10000> create table test (id int, value int) stored as orc;
...
0: jdbc:hive2://localhost:10000> insert into test values (1, 1), (2, 2), (3, 3);
```

```
$ presto --server localhost:8080 --catalog hive
presto> show schemas;
       Schema
--------------------
 default
 information_schema
(2 rows)

Query 20200618_135504_00010_5w9je, FINISHED, 2 nodes
Splits: 19 total, 19 done (100.00%)
0:00 [2 rows, 35B] [8 rows/s, 146B/s]

presto> use default;
USE
presto:default> show tables;
 Table
-------
(0 rows)

Query 20200618_135534_00014_5w9je, FINISHED, 2 nodes
Splits: 19 total, 19 done (100.00%)
0:00 [0 rows, 0B] [0 rows/s, 0B/s]

presto:default> show tables;
 Table
-------
 test
(1 row)

Query 20200618_135653_00015_5w9je, FINISHED, 2 nodes
Splits: 19 total, 19 done (100.00%)

presto:default> select * from test;
 id | value
----|-------
  1 |     1
  2 |     2
  3 |     3
(3 rows)

Query 20200618_140226_00021_5w9je, FINISHED, 1 node
Splits: 17 total, 17 done (100.00%)
0:01 [3 rows, 246B] [4 rows/s, 342B/s]
```
