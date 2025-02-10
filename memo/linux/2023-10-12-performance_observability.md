---
layout: memo
title: Performance observability tools cheatsheet
---

# CPU
- Display statistics for all processors at 1 second intervals.
```sh
mpstat -P ALL 1
```

# Memory
- Display memory statistics at 1 second intervals with human readable format.
```sh
sar -r --human 1
```

# IO
- Display extended statistics at 1 second intervals for device `dev`.
```sh
iostat --human -x $dev 1
```

# Network
- Display network statistics at 1 second intervals for the network interface `eth0`.
```sh
sar --human -n DEV --iface=eth0 1
```

## Sockets
- display listening TCP and UDP sockets
```sh
ss -nltup
```

- dispaloy both listening and non-listening TCP and UDP sockets
```sh
ss -atup
```

- example of state filter
```sh
ss -p state established 'dport = 5432'
```

# Links
- [Linux Performance](https://www.brendangregg.com/linuxperf.html)
  - [USE Method: Linux Performance Checklist](https://www.brendangregg.com/USEmethod/use-linux.html)
- [MemAvailable of /proc/meminfo](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=34e431b0ae398fc54ea69ff85ec700722c9da773)
  - [Linux ate my ram](https://www.linuxatemyram.com/)
- [The PMCs of EC2](https://www.brendangregg.com/blog/2017-05-04/the-pmcs-of-ec2.html)
- [Intel Performance Counter Monitor](https://github.com/intel/pcm)
