#!/bin/bash

# 1. Login to gcloud (this will open a browser window)
echo "Logging in to Google Cloud..."
gcloud auth login

# 2. Set project
echo "Setting project to mlops-cs4..."
gcloud config set project mlops-cs4

# 3. Enable required APIs
echo "Enabling required APIs..."
gcloud services enable compute.googleapis.com

# 4. Create compute instance
echo "Creating compute instance..."
gcloud compute instances create mlops-cs4 \
    --image-family=ubuntu-2004-lts \
    --image-project=ubuntu-os-cloud \
    --machine-type=e2-medium \
    --zone=us-central1-a \
    --boot-disk-size=30GB \
    --tags=http-server \
    --metadata=startup-script='#!/bin/bash
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        apt-get update
        apt-get install -y docker-ce
        # Install prerequisites
        apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            gnupg \
            lsb-release

        # Add Docker official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

        # Add Docker repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Update apt and install Docker
        apt-get update
        apt-get install -y docker-ce docker-ce-cli containerd.io

        # Add current user to docker group
        usermod -aG docker ubuntu

        # Verify Docker is running
        systemctl status docker
        
        apt-get update
        apt-get install -y docker.io
        systemctl start docker
        systemctl enable docker
        # Add the default user to docker group
        usermod -aG docker venkateshroshan95
        # Create the docker group if it doesnt exist
        groupadd -f docker
        # Set proper permissions for Docker socket
        chmod 666 /var/run/docker.sock'


# 5. Create firewall rule
echo "Creating firewall rule..."

gcloud compute firewall-rules create allow-ports \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:7860,tcp:8000,tcp:9100 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server

# Wait for instance to be ready and Docker to be installed
echo "Waiting for instance to be ready..."
sleep 180

# Get the external IP
EXTERNAL_IP=$(gcloud compute instances describe mlops-cs4 --zone=us-central1-a \
    --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

# 7. Pull Docker image
echo "Pulling Docker image..."
gcloud compute ssh mlops-cs4 --zone=us-central1-a --command="docker pull venkateshroshan/mlops-cs4:latest"

# 8. Run Docker container
echo "Running Docker container..."
gcloud compute ssh mlops-cs4 --zone=us-central1-a --command="docker run -d -p 7860:7860 -p 8000:8000 -p 9100:9100 venkateshroshan/mlops-cs4:latest"

# 9 & 10. Get and print external IP
echo "External IP address: $EXTERNAL_IP"

echo "Deployment complete!"
echo "Your application is accessible at:"
echo "http://$EXTERNAL_IP:7860"
echo "http://$EXTERNAL_IP:8000"
echo "http://$EXTERNAL_IP:9100"