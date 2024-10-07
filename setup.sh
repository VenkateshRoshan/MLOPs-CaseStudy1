#! /bin/bash

# Server details
PORT=22013
HOST=paffenroth-23.dyn.wpi.edu
USER=student-admin

ssh_key_path=./
old_ssh_key_name=./student-admin_key

# remove keys if already present
rm -f $ssh_key_path/my_key*

# TODO : Add password to the ssh key and store it in a file and read the file and get the password

# Generate SSH key
ssh-keygen -f my_key -t ed25519 -N ""

# Copy the private key into a variable
# new_ssh_key=$(<my_key)

# # Print the private key
# echo "Private Key:"
# echo "$new_ssh_key"

# Copy the public key into a new_ssh_key variable
new_ssh_pub_key=$(<my_key.pub)

# Print the public key
# echo "Public Key:"
# echo "$new_ssh_pub_key"

# Use the old SSH key to connect to the server and append the new public key to authorized_keys
ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "echo '$new_ssh_pub_key' >> /home/student-admin/.ssh/authorized_keys && chmod 600 /home/student-admin/.ssh/authorized_keys"

echo "New public key added to authorized_keys on the server."

# Make a variable to store the SSH connection command with 
SSH_CONNECTION="ssh -i my_key -p $PORT $USER@$HOST"

# TODO : Comment the old ssh key in the authorized_keys file
# Use the new SSH key to connect to the server and install Docker

echo "Installing Docker on the server..."

$SSH_CONNECTION "sudo apt-get update"

# Install required packages for Docker
echo "Installing required packages for Docker..."
$SSH_CONNECTION "sudo apt-get install -y ca-certificates curl gnupg lsb-release"

# Add Docker's official GPG key
echo "Adding Docker's official GPG key..."
$SSH_CONNECTION "sudo mkdir -p /etc/apt/keyrings"
$SSH_CONNECTION "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"

# Set up the Docker repository
echo "Setting up the Docker repository..."
$SSH_CONNECTION "echo \"deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null"

# Update the package list again
$SSH_CONNECTION "sudo apt-get update"

# Install Docker Engine, Docker CLI, and containerd
echo "Installing Docker Engine, Docker CLI, and containerd..."
$SSH_CONNECTION "sudo apt-get install -y docker-ce docker-ce-cli containerd.io"

# Start and enable Docker service
echo "Starting and enabling Docker service..."
$SSH_CONNECTION "sudo systemctl start docker"
$SSH_CONNECTION "sudo systemctl enable docker"

# Add current user to docker group (to run Docker commands without sudo)
echo "Adding current user to docker group..."
$SSH_CONNECTION "sudo usermod -aG docker $USER"

# Verify Docker installation
$SSH_CONNECTION "docker --version"

echo "Docker has been installed on the server."

# Verify if the key has been added successfully

DOCKER_NAME=mlopscs2


# # Build Docker image locally
# echo "Building Docker image..."
# # docker build -t $DOCKER_NAME .
# docker build --build-arg HF_TOKEN=$HF_TOKEN -t $DOCKER_NAME .

# # Save the Docker image to a tar file
# docker save -o $DOCKER_NAME.tar $DOCKER_NAME

# # Copy the Docker image tar to the server
# echo "Copying Docker image to the server..."
# scp -i "$old_ssh_key_name" -P "$PORT" $DOCKER_NAME.tar "$USER@$HOST:/home/$USER/"

# # Load the Docker image on the server
# $SSH_CONNECTION "docker load -i /home/$USER/$DOCKER_NAME.tar"

# pull the docker image from venkateshroshan/mlops-case-study2:latest
$SSH_CONNECTION "docker pull venkateshroshan/mlops-case-study2:latest"

echo "Docker image has been copied to the server."

# Run the Docker container on the server with restart policy
$SSH_CONNECTION "docker run -d --restart unless-stopped -p 8013:5000 $DOCKER_NAME"

echo "Docker container is running on the server."