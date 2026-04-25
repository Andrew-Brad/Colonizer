# Win 11 Setup

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

It's cleaner to install python globally for the machine and get it in your PATH. A `uv python install` won't do this as it's designed for projects and `venv`.

`winget install -e --id Python.Python.3.12 --scope machine` (or latest version as needed)

## WSL

Open terminal as Admin:

```pwsh
wsl --install
```

There are scripts in this repo that make it easy to toggle the Windows/Hyper-V features for software applications that conflict with them.

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
