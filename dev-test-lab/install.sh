#!/bin/bash

# Install prereqs
apt update
apt install -y python3-pip apt-transport-https ca-certificates curl software-properties-common

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update
apt install -y docker-ce

# docker stack
usermod -aG docker adminuser
docker swarm init

# Install docker-compose
su adminuser -c "mkdir -p /home/adminuser/.local/bin"
su adminuser -c "pip3 install docker-compose --upgrade --user && chmod 754 /home/adminuser/.local/bin/docker-compose"

# Add PATH
printf "\nexport PATH=\$PATH:/home/adminuser/.local/bin\n" >/home/adminuser/.bashrc

exit 0
