# First time setup

## Install Docker via script (OBSOLETE as of 22.10 installer!)

`curl -fsSL https://get.docker.com -o install-docker.sh`

### Walkthrough (if needed)

Source: https://get.docker.com/

Walkthrough: https://youtu.be/YeF7ObTnDwc?list=PLVrjozBRY-MpxW0NXUnxoVOy-e-4GxzBq&t=203

### May or may not need to do this after

`sudo systemctl start docker`
`sudo systemctl enable docker`

### Ensure your install is good

`sudo docker run hello-world`

### Enable swarm mode

`sudo docker swarm init`

## Portainer

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