#Requires -RunAsAdministrator

Write-Host "Disabling Windows Subsystem for Linux..." -ForegroundColor Cyan
dism.exe /online /disable-feature /featurename:Microsoft-Windows-Subsystem-Linux /norestart

Write-Host "Disabling Virtual Machine Platform..." -ForegroundColor Cyan
dism.exe /online /disable-feature /featurename:VirtualMachinePlatform /norestart

Write-Host "`nFeatures disabled. Restarting in 10 seconds... Press Ctrl+C to cancel." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force
