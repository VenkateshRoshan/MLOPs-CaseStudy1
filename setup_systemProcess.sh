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
echo "Public Key:"
echo "$new_ssh_pub_key"

# Use the old SSH key to connect to the server and append the new public key to authorized_keys
ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "echo '$new_ssh_pub_key' >> /home/student-admin/.ssh/authorized_keys && chmod 600 /home/student-admin/.ssh/authorized_keys"

# TODO : Comment the old ssh key in the authorized_keys file
# 

# Verify if the key has been added successfully
echo "New public key added to authorized_keys on the server."

# Make a variable to store the SSH connection command with 
SSH_CONNECTION="ssh -i my_key -p $PORT $USER@$HOST"

# run a command to create apt install python3-venv
# ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "sudo apt-get update && sudo apt-get install python3-venv"
$SSH_CONNECTION "sudo apt-get update && suod apt-get upgrade && sudo apt-get install python3-venv && pip install --upgrade pip"

VENV=/home/$USER/mlops

# creating a virtual environment
# ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "python3 -m venv $VENV"
$SSH_CONNECTION "python3 -m venv $VENV"

echo "Virtual environment created. in $VENV"

# path of git repo
GIT_REPO_PATH=https://github.com/VenkateshRoshan/MLOPs-CaseStudy1.git

# Clone the git repo
# ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "git clone $GIT_REPO_PATH"
$SSH_CONNECTION "git clone $GIT_REPO_PATH"

# Activate the virtual environment
# ssh -i "$old_ssh_key_name" -p "$PORT" "$USER@$HOST" "source $VENV/bin/activate && sudo apt install ffmpeg && cd MLOPs-CaseStudy1 && pip install -r requirements.txt"
$SSH_CONNECTION "source $VENV/bin/activate && sudo apt install ffmpeg && cd MLOPs-CaseStudy1 && pip3 install -r requirements.txt" # python3 app.py" to run the application

echo "The environment is ready to run the application."

# check the pip list in the environment
$SSH_CONNECTION "source $VENV/bin/activate && pip list"

# Create a systemd service file for the application
SERVICE_FILE="[Unit]
Description= <<< MLOps Case Study 1 Deployment >>>
After=network.target

[Service]
Type=simple
ExecStart=/bin/bash -c 'source $VENV/bin/activate && cd /home/$USER/MLOPs-CaseStudy1 && python3 app.py'
Restart=always
User=$USER
WorkingDirectory=/home/$USER/MLOPs-CaseStudy1

[Install]
WantedBy=multi-user.target"

# Write the service file to the server
echo "$SERVICE_FILE" | $SSH_CONNECTION "sudo tee /etc/systemd/system/mlopscs2.service > /dev/null"

# Reload systemd to recognize the new service
$SSH_CONNECTION "sudo systemctl daemon-reload"

# Enable the service to start on boot
$SSH_CONNECTION "sudo systemctl enable mlopscs2"

# Start the service
$SSH_CONNECTION "sudo systemctl start mlopscs2"

# Check the status of the service
# $SSH_CONNECTION "sudo systemctl status mlopscs2"

# # restart the service
# $SSH_CONNECTION "sudo systemctl restart mlopscs2"

# Run the application
$SSH_CONNECTION "source $VENV/bin/activate && cd MLOPs-CaseStudy1 && python3 app.py"

echo "Systemd service for MLOps application created and started."




# The URL Path : paffenroth-23.dyn.wpi.edu:8013 (Gradio Port (8000) + Group Number(13) )


# TODO : Write a docker file , upload it to VM , and run a docker image in the VM and upload it to AWS S3 bucket