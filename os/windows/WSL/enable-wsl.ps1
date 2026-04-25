#Requires -RunAsAdministrator

Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Cyan
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Cyan
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

Write-Host "`nFeatures enabled. Restarting in 10 seconds... Press Ctrl+C to cancel." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force
