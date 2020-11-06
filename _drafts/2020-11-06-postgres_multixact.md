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
- [Multixact members limit exceeded on 9.4](https://www.postgresql-archive.org/Multixact-members-limit-exceeded-td5976890.html)

[^tupheader]: [tuple header layout](https://www.postgresql.org/docs/13/storage-page-layout.html#STORAGE-TUPLE-LAYOUT)
