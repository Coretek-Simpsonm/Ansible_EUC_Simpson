$HKLMregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive'##Path to HKLM keys
$DiskSizeregistryPath = 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive\DiskSpaceCheckThresholdMB'##Path to max disk size key
$TenantGUID = '868ff0dc-2bf2-4324-b4ea-30c40243d37d'

if(!(Test-Path $HKLMregistryPath)){New-Item -Path $HKLMregistryPath -Force}
if(!(Test-Path $DiskSizeregistryPath)){New-Item -Path $DiskSizeregistryPath -Force}

New-ItemProperty -Path $HKLMregistryPath -Name 'SilentAccountConfig' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable silent account configuration
New-ItemProperty -Path $DiskSizeregistryPath -Name $TenantGUID -Value '102400' -PropertyType DWORD -Force | Out-Null ##Set max OneDrive threshold before prompting
New-ItemProperty -Path $HKLMregistryPath -Name 'FilesOnDemandEnabled' -Value '1' -PropertyType DWORD -Force | Out-Null ##Enable files on demand
New-ItemProperty -Path $HKLMregistryPath -Name 'DehydrateSyncedTeamSites' -Value '1' -PropertyType DWORD -Force | Out-Null ##set team files to online only
New-ItemProperty -Path $HKLMregistryPath -Name 'DisablePersonalSync' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $HKLMregistryPath -Name 'DisableOfflineMode' -Value '1' -PropertyType DWORD -Force | Out-Null

