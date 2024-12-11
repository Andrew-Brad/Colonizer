Echo "Profile loaded at $profile.  Type notepad (dollar)profile to edit."

Set-Alias -Name tf -Value terraform

Function binobj
{
 Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
}

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# For starship:
$ENV:STARSHIP_CONFIG = "$HOME\Desktop\Git\Colonizer\app\starship\starship.toml"
Invoke-Expression (&starship init powershell)
