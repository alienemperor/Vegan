#$VMName = Read-Host 'Name of new VM:' 
New-VM -Name Vegan-Production -Generation 2 -SwitchName External -Path C:\Vms\Vegan-Production\

Set-VM -Name Vegan-Production -DynamicMemory -MemoryMinimumBytes 1GB -MemoryMaximumBytes 6GB -MemoryStartupBytes 2GB -ProcessorCount 4

copy C:\VMs\Sysprep\SVR-2012.vhdx C:\VMs\Vegan-Production\Vegan-Production_Disk1.vhdx

Add-VMHardDiskDrive -VMName Vegan-Production -Path C:\VMs\Vegan-Production\Vegan-Production_Disk1.vhdx
