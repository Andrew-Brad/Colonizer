sudo mkdir ~/Desktop/Git &&
cd ~/Desktop/Git &&
git clone https://github.com/Andrew-Brad/Colonizer.git;

# Apps and software
sudo snap install --classic code;
sudo snap install termius-app signal-desktop spotify;

# 1Password
## Snaps don't work with the SSH Agent, so stick with a manual install:
https://support.1password.com/install-linux/#get-1password-for-linux

# Starship
## Also not a great experience using snaps. Do a manual install
https://starship.rs/guide/#step-1-install-starship

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

# Nerd Fonts have a few ways to install them, none are ideal one-liners
Download the target font you want:
https://www.nerdfonts.com/font-downloads
Use `Font Management` app in Kubuntu to install it and verify the name that shows up on your system
For VS Code settings, the 'monospace' error is generic and may not have anything to do with compatibility. It likely means a typo or font not found.

# Another method is a shallow clone of the repo and invoking that install script:
# However I had a different experience based on which terminal I used, so YMMV
# Only works if the font is in the repo, newer ones may not work
git clone --filter=blob:none https://github.com/ryanoasis/nerd-fonts.git
./install.sh `{font}`
Ex:
./install.sh DroidSansMono

# Copy dotfiles as needed: gitconfig, inputrc, bash_aliases etc