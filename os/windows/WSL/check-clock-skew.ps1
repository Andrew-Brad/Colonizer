<#
.SYNOPSIS
    Detect (and optionally fix) Windows host clock skew that poisons WSL2's clock.

.DESCRIPTION
    If the Windows Time service (w32time) is stopped, the host clock free-runs and drifts.
    WSL2 imports host time via /dev/ptp_hyperv, while systemd-timesyncd inside the distro
    independently corrects to real NTP time. The two authorities then fight, and the WSL
    clock oscillates by the size of the host's drift -- snapping forward and back, forever.

    This is nastier than plain drift: monotonic clocks stay sane, so uptime-based code is
    fine, but anything comparing wall-clock deadlines (`deadline = now() + N`) sees the
    deadline jump into the past and fires instantly. It also makes `make` emit
    "Clock skew detected. Your build may be incomplete."

    Discovered 2026-08-13 after a ~15.4s host drift silently broke fishing on a local
    AzerothCore server: the 5-second bite window was consumed by a single clock snap.

.PARAMETER Fix
    Set w32time to Automatic, start it, and force a resync. REQUIRES AN ELEVATED SHELL.

.PARAMETER Samples
    Number of 1-second samples used for jump detection. Default 20.

.EXAMPLE
    .\check-clock-skew.ps1
    Diagnose only. Safe, read-only, no elevation needed.

.EXAMPLE
    .\check-clock-skew.ps1 -Fix
    Diagnose, then repair w32time. Run from an elevated PowerShell.

.NOTES
    After fixing the host, WSL usually reconverges within a minute or two on its own
    (systemd-timesyncd and Hyper-V sync stop disagreeing once the host is correct).
    If it does not, `wsl --shutdown` forces a clean re-import -- but note that this
    stops every running distro and all Docker containers inside WSL.
#>
[CmdletBinding()]
param(
    [switch]$Fix,
    [int]$Samples = 20
)

$ErrorActionPreference = 'Continue'
$NtpServer  = 'time.windows.com'
$JumpMs     = 1000    # divergence above this is a step, not jitter
$OffsetWarn = 2.0     # seconds of host offset considered a problem

function Write-Section($Text) { Write-Host "`n=== $Text ===" -ForegroundColor Cyan }
function Write-Ok     ($Text) { Write-Host "  [OK]   $Text" -ForegroundColor Green }
function Write-Bad    ($Text) { Write-Host "  [FAIL] $Text" -ForegroundColor Red }
function Write-Warn   ($Text) { Write-Host "  [WARN] $Text" -ForegroundColor Yellow }

$problems = @()

# ---------------------------------------------------------------- 1. w32time
Write-Section 'Windows Time service'
$svc = Get-Service w32time -ErrorAction SilentlyContinue
if (-not $svc) {
    Write-Bad 'w32time service not found (unexpected on Windows).'
    $problems += 'w32time-missing'
} else {
    $startType = (Get-CimInstance Win32_Service -Filter "Name='w32time'").StartMode
    Write-Host "  Status: $($svc.Status)   StartMode: $startType"
    if ($svc.Status -ne 'Running') {
        Write-Bad 'w32time is NOT running -- the host clock is free-running and will drift.'
        $problems += 'w32time-stopped'
    } else {
        Write-Ok 'w32time is running.'
    }
    if ($startType -notmatch 'Auto') {
        Write-Warn "StartMode is '$startType'; it will not survive a reboot. Should be Automatic."
        $problems += 'w32time-not-automatic'
    }
}

# ------------------------------------------------- 2. host offset vs true time
Write-Section "Host clock offset vs $NtpServer"
$offset = $null
try {
    $chart = w32tm /stripchart /computer:$NtpServer /samples:5 /dataonly 2>&1 | Out-String
    $vals  = [regex]::Matches($chart, ',\s*([+-][0-9.]+)s') | ForEach-Object { [double]$_.Groups[1].Value }
    if ($vals.Count -gt 0) {
        $offset = ($vals | Measure-Object -Average).Average
        Write-Host ("  Mean offset: {0:+0.000;-0.000;0.000}s over {1} samples" -f $offset, $vals.Count)
        if ([math]::Abs($offset) -gt $OffsetWarn) {
            Write-Bad ("Host clock is off by {0:0.00}s. Expect a +/-{0:0.0}s sawtooth inside WSL." -f [math]::Abs($offset))
            $problems += 'host-offset'
        } else {
            Write-Ok 'Host clock is close to true time.'
        }
    } else {
        Write-Warn "Could not parse w32tm output (service stopped, or network blocked):`n$chart"
    }
} catch {
    Write-Warn "stripchart failed: $_"
}

# --------------------------------------------------------- 3. WSL vs host skew
Write-Section 'WSL clock vs Windows host'
$wslPresent = $null -ne (Get-Command wsl -ErrorAction SilentlyContinue)
if (-not $wslPresent) {
    Write-Warn 'wsl.exe not found; skipping WSL checks.'
} else {
    $skews = foreach ($i in 1..3) {
        $win = [math]::Round(((Get-Date).ToUniversalTime() - [datetime]'1970-01-01').TotalSeconds, 3)
        $raw = (wsl bash -c 'date +%s.%N' 2>$null)
        if ($raw) { [math]::Round([double]($raw.Trim()) - $win, 3) }
        Start-Sleep -Milliseconds 500
    }
    if ($skews) {
        $skews | ForEach-Object { Write-Host ("  skew (WSL - Windows): {0:+0.000;-0.000;0.000}s" -f $_) }
        $worst = ($skews | ForEach-Object { [math]::Abs($_) } | Measure-Object -Maximum).Maximum
        if ($worst -gt $OffsetWarn) {
            Write-Bad ("WSL differs from the host by up to {0:0.00}s." -f $worst)
            $problems += 'wsl-skew'
        } else {
            Write-Ok 'WSL tracks the host clock.'
        }
    } else {
        Write-Warn 'Could not read the WSL clock.'
    }

    # ------------------------------------------------ 4. jump (sawtooth) detect
    Write-Section "WSL clock step detection ($Samples samples, ~$Samples seconds)"
    Write-Host '  Comparing WSL wall-clock deltas against a Windows monotonic reference.'
    $sw       = [System.Diagnostics.Stopwatch]::StartNew()
    $prevWall = [double]((wsl bash -c 'date +%s.%N' 2>$null).Trim())
    $prevMono = $sw.Elapsed.TotalMilliseconds
    $jumps    = 0

    foreach ($i in 1..$Samples) {
        Start-Sleep -Seconds 1
        $wall = [double]((wsl bash -c 'date +%s.%N' 2>$null).Trim())
        $mono = $sw.Elapsed.TotalMilliseconds
        $wd   = ($wall - $prevWall) * 1000
        $md   = $mono - $prevMono
        $div  = $wd - $md
        if ([math]::Abs($div) -gt $JumpMs) {
            $jumps++
            Write-Host ("  wall {0,8:0}ms   mono {1,8:0}ms   div {2,+9:0}ms   <<< JUMP" -f $wd, $md, $div) -ForegroundColor Red
        } else {
            Write-Host ("  wall {0,8:0}ms   mono {1,8:0}ms   div {2,+9:0}ms" -f $wd, $md, $div)
        }
        $prevWall = $wall
        $prevMono = $mono
    }

    if ($jumps -gt 0) {
        Write-Bad "$jumps clock step(s) detected in $Samples samples. Wall-clock deadlines are unreliable."
        $problems += 'wsl-jumps'
    } else {
        Write-Ok "No clock steps in $Samples samples."
    }
}

# ------------------------------------------------------------------- 5. verdict
Write-Section 'Verdict'
if ($problems.Count -eq 0) {
    Write-Ok 'Clock is healthy. Nothing to do.'
} else {
    Write-Bad ("Problems: {0}" -f ($problems -join ', '))
    Write-Host ''
    Write-Host '  Fix (ELEVATED PowerShell):' -ForegroundColor Yellow
    Write-Host '      Set-Service w32time -StartupType Automatic'
    Write-Host '      Start-Service w32time'
    Write-Host '      w32tm /resync /force'
    Write-Host ''
    Write-Host '  Then re-run this script. WSL normally reconverges within a minute or two;'
    Write-Host '  if it does not, `wsl --shutdown` forces it (stops all distros + Docker).'
}

# ----------------------------------------------------------------------- 6. fix
if ($Fix) {
    Write-Section 'Applying fix'
    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Write-Bad 'Not elevated. Re-run this script from an Administrator PowerShell.'
        exit 1
    }

    Set-Service w32time -StartupType Automatic
    Start-Service w32time -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    w32tm /resync /force 2>&1 | ForEach-Object { Write-Host "  $_" }
    Start-Sleep -Seconds 3
    Write-Host ''
    w32tm /query /status 2>&1 | ForEach-Object { Write-Host "  $_" }
    Write-Ok 'Done. Re-run without -Fix to confirm the skew and jumps are gone.'
}
