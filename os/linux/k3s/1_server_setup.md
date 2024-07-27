# Setup For k3s on Ubuntu for Raspberry Pi

[Setup Docs on the k3s Site](https://docs.k3s.io/installation/requirements?os=debian)

## Update Packages

It's a good idea to update all your packages on a fresh install:

```bash
sudo apt update && sudo apt upgrade -y;
```

## Optional Step - Install Misc Tools

```bash
sudo apt install nnn tldr nfs-common htop powertop -y;
```

## Optional - Prepare An Attached SSD As A k3s Data Directory

List out your block devices:

```bash
lsblk
```

Should show the block device: `nvme0n1`.

### Partition the SSD

```bash
sudo parted /dev/nvme0n1
(parted) mklabel gpt
(parted) mkpart primary ext4 0% 100%
(parted) quit

```

### Format the SSD

Note this is the partition name, not *just* the device name. Can still be viewed through `lsblk`.

```bash
sudo mkfs.ext4 /dev/nvme0n1p1
```

### Mount the SSD

```bash
sudo mkdir /mnt/ab-nvme-ssd
sudo mount /dev/nvme0n1p1 /mnt/ab-nvme-ssd
```

### Update `fstab` to ensure the SSD mounts at boot

Get the UUID of the partition:

```bash
sudo blkid /dev/nvme0n1p1
```

Edit the fstab file:

```bash
sudo nano /etc/fstab
```

Add this line, replacing with correct UUID:
`UUID=faaf7f47-1bbd-4691-83dd-4a519e986cdf /mnt/ab-nvme-ssd ext4 defaults 0 2`

Verify your SSD is mounted:
`df -h`

## Requirements - Server Config

```bash
sudo ufw disable
```

## k3s Install

### Run The Install Script

Note that this install references a specific version combination known to match Rancher's [compatibility matrix](https://www.suse.com/suse-rancher/support-matrix/all-supported-versions/rancher-v2-8-5/). Latest Rancher is NOT guaranteed to work with latest k3s!

A separate data directory for k3s is optional, but having an SSD for k3s storage is nice.

```bash
sudo mkdir -p /mnt/ab-nvme-ssd/k3s-data
sudo curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION="v1.28.11+k3s1" sh -s - --data-dir /mnt/ab-nvme-ssd/k3s-data --write-kubeconfig-mode=644
```

Also see [k3s releases](https://github.com/k3s-io/k3s/releases) to reference a desired version.

As another example, multiple configuration values may be used if desired:

```bash
curl -sfL https://get.k3s.io | sh -s - --data-dir /mnt/myssd/k3s --disable traefik --disable servicelb
```

Check k3s status to verify:

```bash
sudo systemctl status k3s
```

Ensure the Kubeconfig file is always referenced as an env variable:

```bash
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
```

## Optional Step - Rancher Install

[Reference Doc](https://ranchermanager.docs.rancher.com/getting-started/installation-and-upgrade#single-node-kubernetes-install)

### Pre-req: Install Helm from github hosted binaries

```bash
sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

#### Validate the Install

```bash
helm version
```

### Pre-req: Install Cert-manager

Cert-manager is required for various cert issuing/signing activities within Rancher. https://cert-manager.io/docs/configuration/

```bash
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.5.3
```

Verify it's running:

```bash
kubectl get pods --namespace cert-manager
```

### Add the Rancher Helm Repository

```bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update
```

### Create a namespace for Rancher and install It

```bash
kubectl create namespace cattle-system
helm install rancher rancher-latest/rancher --namespace cattle-system --version 2.8.4 --set hostname=rancher.homelab --set replicas=1 --set bootstrapPassword=changeme
```

Observe some similar output in your shell:

```txt
NOTE: Rancher may take several minutes to fully initialize. Please standby while Certificates are being issued, Containers are started and the Ingress rule comes up.
```

Rollout may take a minute as the response states. To check in on it:

```bash
kubectl -n cattle-system rollout status deploy/rancher
```

You provided a bootstrap password, so navigate to https://rancher.homelab and enter that. This means you need DNS resolution!

NOTE! As of July 2024, there is a bug if you are on k3s where the provisioned secret (i.e. bootstrap password) is not accepted as the valid password on first time login.

[This issue](https://github.com/rancher/rancher/issues/34686#issuecomment-1973325097) captures a workaround. Use `kubectl` to invoke a password reset inside the Rancher pod:

```bash
kubectl -n cattle-system exec $(kubectl -n cattle-system get pods -l app=rancher | grep '1/1' | head -1 | awk '{ print $1 }') -- reset-password
```

From there on, it's all you!
