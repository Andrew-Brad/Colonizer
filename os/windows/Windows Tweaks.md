# Turn off the stupid Aero shake feature

<https://mywindowshub.com/enable-disable-aero-shake-windows-10/>

## Gaming FPS

Lots of guides out there on quick windows settings to change to improve FPS

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
