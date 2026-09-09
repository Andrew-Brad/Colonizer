#Requires -RunAsAdministrator

Write-Host "Enabling Windows Subsystem for Linux..." -ForegroundColor Cyan
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

Write-Host "Enabling Virtual Machine Platform..." -ForegroundColor Cyan
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Keep the Windows Time service disciplined. w32time ships as Manual on workgroup machines,
# triggered by DOMAIN JOINED STATUS -- a trigger that never fires when you aren't domain-joined,
# so it can sit stopped for months while the host clock drifts off the RTC. WSL2 then imports
# the bad host time via /dev/ptp_hyperv while systemd-timesyncd corrects to real NTP, and the
# two fight: the WSL wall clock oscillates by the size of the drift. Monotonic clocks stay
# fine, so this hides from every latency metric and only breaks wall-clock deadline code.
# Cost us a long AzerothCore fishing investigation on 2026-08-13 (host was +15.41s off).
# Automatic is the part that sticks -- starting it once only fixes today.
# See clock-skew-onboarding.md and check-clock-skew.ps1 in this directory.
Write-Host "Ensuring Windows Time service is enabled and synced..." -ForegroundColor Cyan
Set-Service w32time -StartupType Automatic
Start-Service w32time -ErrorAction SilentlyContinue
w32tm /resync /force 2>&1 | Out-Null
$offset = w32tm /stripchart /computer:time.windows.com /samples:3 /dataonly 2>&1 |
    Select-String -Pattern ',\s*([+-][0-9.]+)s' |
    ForEach-Object { [double]$_.Matches[0].Groups[1].Value } |
    Measure-Object -Average | Select-Object -ExpandProperty Average
if ($null -ne $offset) {
    $color = if ([math]::Abs($offset) -gt 2) { 'Red' } else { 'Green' }
    Write-Host ("  Host clock offset: {0:+0.000;-0.000;0.000}s" -f $offset) -ForegroundColor $color
} else {
    Write-Host "  Could not measure clock offset (network blocked?)." -ForegroundColor Yellow
}

Write-Host "`nFeatures enabled. Restarting in 10 seconds... Press Ctrl+C to cancel." -ForegroundColor Yellow
Start-Sleep -Seconds 10
Restart-Computer -Force
