#!/bin/bash

# Install prereqs
apt update
apt install -y python3-pip apt-transport-https ca-certificates curl software-properties-common

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce

# Install docker-compose
su - ubuntu -c "mkdir -p $HOME/.local/bin"
su - ubuntu -c "pip3 install docker-compose --upgrade --user && chmod 754 $HOME/.local/bin/docker-compose"
usermod -aG docker ubuntu

# Add PATH
printf "\nexport PATH=\$PATH:$HOME/.local/bin\n" >$HOME/.bashrc

exit 0
