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

# Create EFI partition
1. Create a primary partition with `fat32` file syste and set `esp` flag.
2. Format the partition
```sh
mkfs.fat -F 32 /dev/sdxY
```
3. Mount the partition on `/efi` or `/boot/efi`
  - `/efi` is a replacement for the historical and now discouraged ESP mountpoint `/boot/efi`.
  - The `/efi` directory is not available by default, you will need to first create it before mounting the ESP to it.
4. Install grub (without partition number)
```sh
grub-install /dev/sdx
```
5. Generate initramfs image
```sh
update-initramfs -u -k all
```
6. Generate grub config file
```sh
update-grub
```
7. Reboot

- [EFI system partition](https://wiki.archlinux.org/title/EFI_system_partition)
- [GRUB](https://wiki.archlinux.org/title/GRUB)
- [move bootloder](https://askubuntu.com/questions/1250199/move-bootloader-or-remove-efi-partition-in-second-drive)
- [update-grubの仕組みを使ってUbuntuのGRUBをさらにカスタマイズする](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0746)

# Check S.M.A.R.T
Use [smartmontools](https://www.smartmontools.org/)

```sh
smartctl --all /dev/sda
```

## Links
- [Archlinux doc for S.M.A.R.T](https://wiki.archlinux.org/title/S.M.A.R.T.)
