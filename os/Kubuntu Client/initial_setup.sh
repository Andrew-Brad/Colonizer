#!/usr/bin/env bash

sudo mkdir ~/Desktop/Git &&
cd ~/Desktop/Git &&
git clone https://github.com/Andrew-Brad/Colonizer.git;

# Apps and software
sudo snap install --classic code;
sudo snap install termius-app signal-desktop 1password;

# Also copy git and bash files as appropriate
echo "Script is complete installing snaps. Execute 'reload' in your shell, and copy your .git files and bash files as needed!";