#!/bin/bash
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt and install Docker
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable Docker
systemctl start docker
systemctl enable docker

# Create docker group and add user
groupadd -f docker
usermod -aG docker ubuntu

# Set proper permissions for Docker socket
chmod 666 /var/run/docker.sock