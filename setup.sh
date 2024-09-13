#!/bin/bash

# Define the path to the virtual environment
VENV_DIR="path/to/venv"

# Create the virtual environment
python3 -m venv $VENV_DIR

# Activate the virtual environment
source $VENV_DIR/bin/activate

# Install required packages
pip3 install -r requirements.txt

# Message to confirm installation completion
echo "Python environment setup is complete, and packages are installed."
