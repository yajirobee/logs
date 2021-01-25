---
layout: memo
title: Logical replication code reading
---

Memo for logical replication code reading

# Replication side
As of https://github.com/postgres/postgres/tree/REL_12_5

- Boot flow
  - logical replication launcher assign a subscription to a slot
  - [bgworker launch](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/postmaster/bgworker.c#L701) logical replication apply worker

## Logical replication launcher
[Entry point](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L972)

+ [list subscriptions](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L1021)
+ [launch logical replication worker](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L294)  
Wait if replication slot is not available.


## Logical replication apply worker
[Entry point](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L1605)
