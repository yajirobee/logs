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

Then, a repair operation will run on the background. 
You can find the progress of jobs by [Get-StorageJob](https://learn.microsoft.com/en-us/powershell/module/storage/get-storagejob).

```
PS C:\>Get-StorageJob
Name                  ElapsedTime           JobState              PercentComplete       IsBackgroundTask
----                  -----------           --------              ---------------       ----------------
Regeneration          00:00:00              Running               50                    True
```

After the repair operation will complete and the virtual disk status will become "Healthy", the retired physical disk can be removed from the storage pool.
```powershell
$PDToRemove = Get-PhysicalDisk -Friendlyname $name
Remove-PhysicalDisk -StoragePoolFriendlyName $poolname -PhysicalDisks $PDToRemove
```

## Fix physical disk state OperationalStatus = Split
see [Drive (physical disk) states](https://learn.microsoft.com/en-us/windows-server/storage/storage-spaces/storage-spaces-states#drive-physical-disk-states)

```powershell
Reset-PhysicalDisk -FriendlyName $name
Repair-VirtualDisk -FriendlyName $vdiskname
```

## Enable auto attach of virtual disks
```powershell
Get-VirtualDisk | Set-VirtualDisk -ismanualattach $false
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