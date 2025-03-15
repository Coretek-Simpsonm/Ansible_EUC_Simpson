Write-Output " Configuring session timeout policies..."
& reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxDisconnectionTime /t REG_DWORD /d 21600000 /f
& reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v MaxIdleTime /t REG_DWORD /d 900000 /f