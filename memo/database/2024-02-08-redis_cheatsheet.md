---
layout: memo
title: Redis cheatsheet
---

# Commands
- Get bytes of a key and its value: [MEMORY USAGE](https://redis.io/docs/latest/commands/memory-usage/)

# Redis cluster

## Transaction in a hash slot with Jedis
```java
Jedis jedisNodeConnection= jedisCluster.getConnectionFromSlot(JedisClusterCRC16.getSlot(hashKey(key)));
jedisNodeConnection.watch(hashKey(key));
Transaction transaction = jedisNodeConnection.multi();
transaction.set(hashKey(key), String.valueOf(item));
transaction.exec();
jedisNodeConnection.close();
```
([Reference](https://groups.google.com/g/jedis_redis/c/b-65UX8qvOE))

# Performance
- [Diagnosing latency issues](https://redis.io/docs/latest/operate/oss_and_stack/management/optimization/latency/)

## Links
- [Redis cluster specification](https://redis.io/docs/reference/cluster-spec/)
- [Redis Clustering Best Practices](https://redis.com/blog/redis-clustering-best-practices-with-keys/)
- [Lua and Redis functions](https://redis.io/docs/latest/develop/interact/programmability/)
