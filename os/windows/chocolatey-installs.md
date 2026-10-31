# Chocolatey Installs

<https://chocolatey.org/install>

Open up Powershell as Admin, or use `sudo` on Windows Terminal.
`Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`

## Native Installs Only

Proton Suite, Synology, TMOG

## Package Installs

`-? (show help)`
`-v (verbose logging)`
`-y (auto accept prompts and license agreements)`

### Gotta Have It

choco install microsoft-windows-terminal -y
choco install nerd-fonts-droidsansmono -y
choco install starship -y
choco install firefox -y --params "/NoDesktopShortcut"
choco install 1password -y
choco install everything -y
choco install vlc -y
choco install signal -y --params "/NoShortcut"
choco install steam -y
choco install epicgameslauncher -y
choco install discord -y
choco install vcredist2010 -y
choco install putty -y
choco install etcher -y
choco install winscp -y
choco install rufus -y
choco install deluge -y

### Dev Tools

Note that we no longer install dotnetsdk from here, it is managed by `dotnetup`.

choco install vscode azure-cli git.install -y
choco install vcredist2012 -y
choco install sourcetree -y
choco install dbeaver -y
choco install fiddler -y
choco install nodejs -y
choco install python -y
choco install pip -y
choco install terraform -y
choco install 7zip.install -y
choco install winrar -y

### System/Monitoring/Backup

choco install cpu-z -y
choco install hyperx-ngenuity -y # HyperX's accessory lighting tool
choco install nzxt-cam -y

### Fun Stuff

choco install teamviewer -y
choco install licecap -y

## Misc

When complete, this will refresh your PATH and environment variables - some installs require a hard restart of terminal

`refreshenv`

### Other random stuff

Pulover's Macro Creator (GUI over AHK)
