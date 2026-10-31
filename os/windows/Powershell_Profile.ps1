<# 
From the root of this repo, copy this profile to the user's profile:
$src = '.\os\windows\Powershell_Profile.ps1'
$dst = $profile
$dir = Split-Path $dst
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
if (-not (Test-Path $dst) -or (Get-Item $dst).Length -eq 0) {
    Copy-Item $src $dst -Force
    Write-Output "Copied profile to $dst"
} else {
    Write-Output "Profile exists and is not empty; no action taken"
}
#>

Echo "Profile loaded at $profile.  Type notepad (dollar)profile to edit."

# Default starting directory: only when the shell opened in the home folder, so launches
# that pass an explicit directory (e.g. "Open in Terminal" from Explorer) are left alone.
$GitHome = Join-Path $HOME 'Desktop\Git'
if ((Get-Location).Path -eq $HOME -and (Test-Path $GitHome)) { Set-Location $GitHome }

Set-Alias -Name tf -Value terraform
Set-Alias -Name cl -Value Clear-Host

# Ported from os/linux/.bash_aliases (functions, since PS aliases can't hold commands/args)
function ..    { Set-Location .. }
function ...   { Set-Location ..\.. }
function ....  { Set-Location ..\..\.. }
function ..... { Set-Location ..\..\..\.. }
function dirdownloads { Set-Location (Join-Path $HOME 'Downloads') }
function dirdesktop   { Set-Location (Join-Path $HOME 'Desktop') }
function dirgit       { Set-Location (Join-Path $HOME 'Desktop\Git') }
function dircolonizer { Set-Location (Join-Path $HOME 'Desktop\Git\Colonizer') }
function g       { git status @args }
function gitgud  { git add -A && git commit --amend --no-edit && git push -f }
function path    { $env:PATH -split ';' }

Function binobj {
  Get-ChildItem .\ -include bin, obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
}

# Prefix history search (bash-style): cycles through previous commands starting with your terminal text
if (Get-Module -ListAvailable PSReadLine) {
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# For starship:
$ENV:STARSHIP_CONFIG = "$HOME\Desktop\Git\Colonizer\app\starship\starship.toml"
Invoke-Expression (&starship init powershell)
