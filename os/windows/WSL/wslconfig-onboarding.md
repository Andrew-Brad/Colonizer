# Global WSL2 Config (`.wslconfig`)

Goal: apply Colonizer's managed `.wslconfig` so all WSL2 distros use mirrored
networking and any other host-wide WSL settings.

## File scope

Two distinct WSL config files exist — don't confuse them:

| File | Location | Scope | What it controls |
|---|---|---|---|
| `wsl.conf` | `/etc/wsl.conf` (inside distro) | Per-distro | systemd, automount, default user, interop |
| `.wslconfig` | `%USERPROFILE%\.wslconfig` (Windows host) | All WSL2 distros | networkingMode, memory, CPUs, kernel |

This doc covers the second one. For per-distro setup (systemd, default user),
see `wsl.conf` and the relevant distro onboarding docs.

## 1. Apply repo-managed `.wslconfig`

Source file in this repo:
- `os/windows/WSL/wslconfig`

Run in PowerShell:

```powershell
Copy-Item "C:\Users\Andrew\Desktop\Git\Colonizer\os\windows\WSL\wslconfig" "$HOME\.wslconfig" -Force
Get-Content "$HOME\.wslconfig"
```

Then restart WSL so the new config takes effect:

```powershell
wsl --shutdown
```

## 2. Verify

After WSL restarts (next time you open a distro):

```powershell
wsl -- ip -4 addr show eth0
```

With mirrored networking, the WSL `eth0` IP matches the Windows host adapter
rather than a `172.x.x.x` virtual subnet. From Windows, `localhost:<port>`
should reach services bound inside WSL reliably (no port-forwarding flakiness).

## 3. Why mirrored networking

Default WSL2 networking puts the distro on a virtual NAT subnet and forwards
`localhost` between Windows and WSL. The forwarding is best-effort and breaks
down under load — symptoms include intermittent `connection refused` from
Windows-side clients to services running inside WSL (databases, Docker
containers exposing ports, etc.).

Mirrored mode (Windows 11 + WSL 2.0+) shares the Windows network stack with
the WSL VM, so `localhost` is genuinely shared and connections are reliable.

## 4. References

- Microsoft WSL config reference: https://learn.microsoft.com/windows/wsl/wsl-config
- Mirrored networking announcement: https://devblogs.microsoft.com/commandline/windows-subsystem-for-linux-september-2023-update/
