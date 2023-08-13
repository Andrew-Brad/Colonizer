# Install Docker via script 

`curl -fsSL https://get.docker.com -o install-docker.sh`

## Walkthrough (if needed)

Source: https://get.docker.com/

Walkthrough: https://youtu.be/YeF7ObTnDwc?list=PLVrjozBRY-MpxW0NXUnxoVOy-e-4GxzBq&t=203



## May or may not need to do this after
`sudo systemctl start docker`

`sudo systemctl enable docker`

## Ensure your install is good
`sudo docker run hello-world`

# Portainer
`docker volume create portainer_data`
`docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest`

# Monitoring stack with prometheus/grafana
## Make the directory to hold the config file

`sudo mkdir /etc/prometheus && cd /etc/prometheus`

## Then curl down my copy for convenience
`curl -O <my github url to prometheus.yml>`
