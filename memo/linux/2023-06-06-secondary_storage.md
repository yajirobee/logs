---
layout: memo
title: Cheatsheet for secondary storage manipulation
---

# Clone a block device to another
Use [GNU ddrescue](https://www.gnu.org/software/ddrescue/).
(Do not confuse with [dd_rescue](http://www.garloff.de/kurt/linux/ddrescue/).)

```sh
ddrescue -n -f input output mapfile
```
With mapfile, you can interrupt the copy anytime and resume it later.

# Check S.M.A.R.T
Use [smartmontools](https://www.smartmontools.org/)

```sh
smartctl --all /dev/sda
```

## Links
- [Archlinux doc for S.M.A.R.T](https://wiki.archlinux.org/title/S.M.A.R.T.)
