Echo "Profile loaded at $profile.  Type notepad (dollar)profile to edit."

Set-Alias -Name tf -Value terraform

Function binobj
{
 Get-ChildItem .\ -include bin,obj -Recurse | foreach ($_) { remove-item $_.fullname -Force -Recurse }
}

# Still not sure how shared Cmder installs pass through portable profiles
# https://github.com/cmderdev/cmder/issues/505
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
