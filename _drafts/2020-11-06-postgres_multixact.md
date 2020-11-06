---
layout: blog
title: "Study Multiple Transaction ID"
---

I faced a Multixact ID exhaustion issue recently. AFAIK, not so much documentations are available about 
Multixact ID. This is a memo of my study to understand how Multixact ID works.
<!--end_excerpt-->

The error I faced was as follows.

> ERROR: multixact “members” limit exceeded   Detail: This command would create a multixact with 2 members, but the remaining space is only enough for 1 member.
Hint: Execute a database-wide VACUUM in database with OID 16404 with reduced vacuum_multixact_freeze_min_age and vacuum_multixact_freeze_table_age settings.

# References
- [Multixacts and Wraparound](https://www.postgresql.org/docs/13/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND)
- [PostgreSQL README of tuplock](https://github.com/postgres/postgres/blob/master/src/backend/access/heap/README.tuplock)
- [Multixact members limit exceeded on 9.4](https://www.postgresql-archive.org/Multixact-members-limit-exceeded-td5976890.html)
