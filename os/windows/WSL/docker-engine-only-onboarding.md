# Docker Engine Only in WSL (Ubuntu 24.04)

Goal: install Docker Engine inside this WSL distro only, with no Docker Desktop dependency.

## 1. Apply repo-managed WSL config

Source file in this repo:
- `os/windows/WSL/wsl.conf`

Run in Ubuntu WSL:

```bash
sudo cp /mnt/c/Users/Andrew/Desktop/Git/Colonizer/os/windows/WSL/wsl.conf /etc/wsl.conf
sudo chmod 644 /etc/wsl.conf
cat /etc/wsl.conf
```

Then restart WSL from PowerShell:

```powershell
wsl --shutdown
```

Notes:
- The provided `wsl.conf` sets `systemd=true` and standard automount/interop defaults.
- It also sets `default=andrew` under `[user]`. If your Linux username differs, edit that value before copying.

## 2. Verify baseline

Run in PowerShell:

```powershell
wsl -l -v
wsl -d Ubuntu-24.04 -e bash -lc 'systemctl is-system-running || true'
```

Expected:
- `Ubuntu-24.04` is on WSL2.
- `systemctl` works (degraded is acceptable in WSL if core services are still usable).

## 3. Install Docker Engine from Docker's apt repo

Run in Ubuntu WSL:

```bash
set -e

# Remove conflicting packages if present
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

# Prereqs
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings

# Docker GPG key
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Docker apt source
sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## 4. Start and enable services

```bash
sudo systemctl enable --now containerd
sudo systemctl enable --now docker
sudo systemctl status docker --no-pager -l
```

## 5. Rootful usage model (recommended for this repo)

Option A: always use `sudo` with docker commands.

Option B: use `docker` group (more convenient, but root-equivalent access):

```bash
sudo usermod -aG docker "$USER"
```

Then restart session:

```powershell
wsl --shutdown
```

Reopen Ubuntu and verify:

```bash
docker version
docker run --rm hello-world
docker compose version
```

## 6. Recommended daemon defaults for dev machines

```bash
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<EOF
{
  "features": { "buildkit": true },
  "log-driver": "local"
}
EOF

sudo systemctl restart docker
```

## 7. Quick troubleshooting

- If `Cannot connect to the Docker daemon`:
  - `sudo systemctl status docker`
  - `sudo systemctl restart docker`
- If non-root user cannot run docker after group add:
  - run `wsl --shutdown`, reopen WSL, retry.
- If startup shell errors appear after copying dotfiles from Windows:
  - run `sed -i 's/\r$//' ~/.bashrc ~/.bash_aliases`

## 8. References

- Docker Engine on Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- Docker Linux post-install: https://docs.docker.com/engine/install/linux-postinstall/
- Microsoft WSL systemd: https://learn.microsoft.com/windows/wsl/systemd