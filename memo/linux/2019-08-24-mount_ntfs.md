---
layout: memo
title: Mount NTFS
---

Operation memo to mount NTFS on ubuntu.

# Basic Data Partition
1. Install ntfs-3g
```
# apt-get install ntfs-3g
```

2. Add mount configuration
Check UUID of a partition and add following line on `/etc/fstab`
```
UUID={volume UUID}   {mount_point}     ntfs-3g defaults        0       0
```

# LDM
1. Install ntfs-3g and ldmtool
```
# apt-get install ntfs-3g
```

2. Create device-mapper device on boot time.
e.g. Add a systemd unit like

```
[Unit]
Description=Windows Dynamic Disk Mount
Before=local-fs-pre.target
DefaultDependencies=no
[Service]
Type=simple
User=root
ExecStart=/usr/bin/ldmtool create all
[Install]
WantedBy=local-fs-pre.target
```

3. Add mount configuration
```
/dev/mapper/ldm_vol_{volume_identifier}      {mount_point}       ntfs-3g defaults        0       0
```

# Smb
1. Install cifs-utils
```sh
# apt-get install cifs-utils
```

2. Add mouint configuration
```
//{file_server_ip}/{access_path} {mount_point}  cifs    _netdev,username=...,password=...,uid=...,gid=...    0       0
```

## Specify charset of path names
```
iocharset=utf8
```

# References
- [NTFS-3G intro for archilinux](https://wiki.archlinux.org/index.php/NTFS-3G)
- [man mount.cifs(8)](https://www.samba.org/~ab/output/htmldocs/manpages-3/mount.cifs.8.html)
