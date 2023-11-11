# First time setup

## Install Packages

```bash
sudo apt update && sudo apt upgrade -y;
sudo apt install tldr nfs-common htop -y;
```

## Get NFS Shares Online

```bash
sudo mkdir /home/user/homelab_nfs;
sudo mount -t nfs 192.168.1.X:/nas_target_dir /home/user/homelab_nfs
echo "192.168.1.X:/volume1/nas_target_dir /home/warden/homelab_nfs nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab
```

### Optional: Auto-mount using fstab


## Install Docker via script

```bash
curl -fsSL https://get.docker.com -o install-docker.sh
sudo bash ./install-docker.sh
```

### Walkthrough (if needed)

Source: <https://get.docker.com/>

Walkthrough: <https://youtu.be/YeF7ObTnDwc?list=PLVrjozBRY-MpxW0NXUnxoVOy-e-4GxzBq&t=203>

### May or may not need to do this after

`sudo systemctl start docker`
`sudo systemctl enable docker`

### Ensure your install is good

`sudo docker run hello-world`

### Enable swarm mode

`sudo docker swarm init`

## Portainer in Swarm Mode - linux-amd64-2.19.1

<https://docs.portainer.io/start/install/server/swarm/linux>

1.

```bash
curl -L https://downloads.portainer.io/ee2-19/portainer-agent-stack.yml -o portainer-agent-stack.yml
```

2.

```bash
docker stack deploy -c portainer-agent-stack.yml portainer
```

(Obsolete) These ONLY work for docker standalone:
`docker volume create portainer_data`
`docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest`

### Restore portainer data

In the UI you can restore from a backup settings file.

## Monitoring stack with prometheus/grafana

## Make the directory for the config file

`sudo mkdir /etc/prometheus && cd /etc/prometheus`

 Then curl down my copy for convenience:

`curl -O https://github.com/Andrew-Brad/Colonizer/blob/master/os/Linux%20Server/prometheus.yml`

## Importing Dashboards

Just plug in the id of the dashboard

Server/hardeware metrics: https://grafana.com/grafana/dashboards/1860-node-exporter-full/

cAdvisor: https://grafana.com/grafana/dashboards/14282-cadvisor-exporter/