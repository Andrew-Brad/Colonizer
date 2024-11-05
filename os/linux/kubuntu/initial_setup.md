sudo mkdir ~/Desktop/Git &&
cd ~/Desktop/Git &&
git clone https://github.com/Andrew-Brad/Colonizer.git;

# Apps and software
sudo snap install --classic code;
sudo snap install starship --edge;
sudo snap install termius-app signal-desktop 1password spotify;

# docker:
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
# Add Docker's official GPG key:
sudo apt-get update;
sudo apt-get install ca-certificates curl;
sudo install -m 0755 -d /etc/apt/keyrings;
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc;
sudo chmod a+r /etc/apt/keyrings/docker.asc;

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null;
sudo apt-get update;

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin;
sudo docker run hello-world;

# Nerd Fonts have their own verbose install process on Linux
# One method is a shallow clone of the repo and invoking that install script:
# Only works if the font is in the repo, newer ones may not work
git clone --filter=blob:none https://github.com/ryanoasis/nerd-fonts.git
./install.sh DroidSansMono

# Copy git and bash files as appropriate