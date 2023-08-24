---
layout: memo
title: Use rr debugger
---

# Trouble shooting
- `rr needs /proc/sys/kernel/perf_event_paranoid <= 1, but it is 4.`
```sh
sudo echo kernel.perf_event_paranoid=1 >> /etc/sysctl.d/99-perf.conf
sudo sysctl --system
```

