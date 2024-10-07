import subprocess
import os
import time

PORT=22013
HOST='paffenroth-23.dyn.wpi.edu'

def deploy():
    print(f'Deploying the app...')
    try:
        # Run the setup.sh script
        result = subprocess.run(
            ['./setup.sh'],  # Command to execute
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=True  # Raise an exception for non-zero exit codes
        )
        print(result.stdout.decode())  # Print standard output from the script
    except subprocess.CalledProcessError as e:
        print(f"Error occurred while deploying: {e.stderr.decode()}")

def checkStatus(HOST, PORT):
    print(f'Checking the status of the app...')
    try:
        # Run the netcat (nc) command to check if the port is open
        result = subprocess.run(
            ['nc', '-vz', HOST, str(PORT)],
            stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )
        
        # If the return code is 0, the connection was successful
        if result.returncode == 0:
            print(f"Connection to {HOST}:{PORT} successful.")
            return True
        else:
            print(f"Connection to {HOST}:{PORT} refused.")
            return False
    except Exception as e:
        print(f"Error occurred: {e}")
        return False

def monitorStatus(HOST, PORT, checkInterval=5): # for 5 seconds will wait if the port is not available
    print(f'Monitoring the status of the app...')
    status=False
    while True:
        if checkStatus(HOST, PORT):
            # If the connection is successful, run deploy and exit the loop
            if not status:
                print('Deploying the app...')
                deploy()
            status=True
        else:
            # If connection is refused, wait and retry
            print(f"Waiting for the server {HOST}:{PORT} to become available...")
            time.sleep(checkInterval)
            status = False

# checkStatus(HOST, PORT)
monitorStatus(HOST, PORT)