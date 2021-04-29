---
layout: memo
title: Logical replication code reading
---

Memo for logical replication code reading

# Replication side
As of [12.5](https://github.com/postgres/postgres/tree/REL_12_5)

- Boot flow
  - logical replication launcher assign a subscription to a slot (set slot as main arg)
  - [bgworker launch](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/postmaster/bgworker.c#L701) logical replication apply worker

## Logical replication launcher
[Entry point](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L972)

+ [list subscriptions](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L1021)
+ [launch logical replication worker](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/launcher.c#L294)  
Wait if replication slot is not available.


## Logical replication apply worker
[Entry point](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L1605) Note : this entry point is used for both replication apply worker and table synchronization worker.

### Bootstrap
+ Launch replication apply worker
  + Get replication origin (RepOriginId)
  + Connect to publisher
  + Start streaming
  + Enter [main loop](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L1131)

### Main loop
Receive WAL and process based on ([Replication Protocol](https://www.postgresql.org/docs/12/protocol-replication.html))

+ Process messages until the buffer will be empty (inner loop)
  + "XLogData (B)"
    + [apply dispatch](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L989)
  + "Primary keepalive message (B)"
    + [send feedback](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L1359) Send "Standby status update (F)"
+ send_feedback
+ [reread subscription and process syncing tables if not in remote transaction](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/worker.c#L1248-L1260)
  + Process all tables that are being synchronized
    + [Launch a table synchronization worker](https://github.com/postgres/postgres/blob/6bb1b38fa5388a4aa39ed9e56ef477f618fb28e1/src/backend/replication/logical/tablesync.c#L513)
