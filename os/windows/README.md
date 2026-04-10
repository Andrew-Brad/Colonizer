# Turn off the stupid Aero shake feature

<https://mywindowshub.com/enable-disable-aero-shake-windows-10/>

## Install Powershell 7

From [Ardalis](https://ardalis.com/install-nerd-fonts-terminal-icons-pwsh-7-win-11/)

(and don't forget to update your Terminal app with that default shell)

```pwsh
$PSVersionTable.PSVersion
```

```pwsh
winget install --id Microsoft.PowerShell --source winget
```

### Nerd Fonts with Powershell 7

No 'true' automated install works for these, but there's a pretty useful helper script to automate most of the tedium: https://github.com/jpawlowski/nerd-fonts-installer-PS

## Dev Tools

```pwsh
winget install --id=astral-sh.uv  -e
```

Followed by a `uv python install`.

## DNS

### If you're not self-hosting a DNS server, consider setting this box to go out to Cloudflare DNS

#### List out your interfaces

Get-DnsClientServerAddress

#### Assign Client-Side DNS

Set-DnsClientServerAddress -InterfaceAlias Ethernet -ServerAddresses "1.1.1.1","1.0.0.1"

## Enable WSL

Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

## Enable Some Powershell Scripts

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
