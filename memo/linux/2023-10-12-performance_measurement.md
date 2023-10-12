---
layout: memo
title: Performance measurement cheatsheet
---

# CPU
- Display statistics for all processors at 1 second intervals.
```sh
mpstat -P ALL 1
```

# IO
- Display extended statistics at 1 second intervals for device `dev`.
```sh
iostat -x $dev 1
```

# Network
- Display network statistics at 1 second intervals for the network interface `eth0`.
```sh
sar -n DEV --iface eth0 1
```
