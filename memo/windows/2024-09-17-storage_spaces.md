---
layout: memo
title: Storage Spaces
---

# Operation
Use a PowerShell session as an administrator

## Replace disk of storage pool
```powershell
# check friendly name to add and delete
Get-PhysicalDisk -CanPool $True
$PDToAdd = Get-PhysicalDisk -FriendlyName $name
Add-PhysicalDisk -StoragePoolFriendlyName $poolname -PhysicalDisks $PDToAdd
Set-PhysicalDisk –FeiendlyName $name –Usage Retired
Repair-VirtualDisk -FriendlyName $vdiskname -Asjob
```

## Fix physical disk state OperationalStatus = Split
see [Drive (physical disk) states](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-states#drive-physical-disk-states)

```powershell
Reset-PhysicalDisk -FriendlyName $name
Repair-VirtualDisk -FriendlyName $vdiskname
```

# PowerShell Commands
- list physical disks
```powershell
Get-PhysicalDisk
Get-StoragePool -FrindlyName $poolname | Get-PhysicalDisk
```
- list virtual disks
```powershell
Get-VirtualDisk
```
- list background storage jobs
```powershell
Get-Storagejob
```

# Links
- [Deploy Storage Spaces on a stand-alone server](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/deploy-standalone-storage-spaces)
- [Troubleshoot Storage Spaces](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-states)
- [記憶域のディスク交換](https://www.tksoft.work/system/microsoft/windows/1748)
- [記憶域スペースの容量が足りなくなってきたので、ディスクを交換してみた](https://satsumahomeserver.com/blog/301509)