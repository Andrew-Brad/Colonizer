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

Set-Alias -Name tf -Value terraform

Function binobj {
  Get-ChildItem .\ -include bin, obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# For starship:
$ENV:STARSHIP_CONFIG = "$HOME\Desktop\Git\Colonizer\app\starship\starship.toml"
Invoke-Expression (&starship init powershell)
