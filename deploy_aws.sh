#!/bin/bash

# Variables
CLUSTER_NAME="CS553"
TASK_DEFINITION_NAME="CSS553_CaseStudy_4"
CONTAINER_NAME="CaseStudy4Image"
IMAGE_URI="venkateshroshan/mlops-cs4:latest"
VCPU="0.5"
MEMORY="2048"
PORT="7860"
SECURITY_GROUP_NAME="CS553-SG"

echo "Starting ECS setup..."

# Step 1: Create ECS Cluster
echo "Creating ECS cluster: $CLUSTER_NAME..."
aws ecs create-cluster --cluster-name $CLUSTER_NAME
echo "ECS cluster $CLUSTER_NAME created successfully."

# Step 2: Register Task Definition
echo "Registering task definition: $TASK_DEFINITION_NAME..."
aws ecs register-task-definition \
    --family $TASK_DEFINITION_NAME \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu $VCPU \
    --memory $MEMORY \
    --container-definitions "[
        {
            \"name\": \"$CONTAINER_NAME\",
            \"image\": \"$IMAGE_URI\",
            \"portMappings\": [
                {
                    \"containerPort\": $PORT,
                    \"protocol\": \"tcp\"
                }
            ],
            \"essential\": true
        }
    ]"
echo "Task definition $TASK_DEFINITION_NAME registered successfully."

# Step 3: Get Default VPC ID
echo "Retrieving default VPC ID..."
VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)
if [ -z "$VPC_ID" ]; then
    echo "Error: Default VPC not found. Exiting."
    exit 1
fi
echo "Default VPC ID: $VPC_ID."

# Step 4: Create Security Group
echo "Creating security group: $SECURITY_GROUP_NAME..."
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name $SECURITY_GROUP_NAME --description "Security group for CS553 task" --vpc-id $VPC_ID --query 'GroupId' --output text)
echo "Security group created with ID: $SECURITY_GROUP_ID."

# Step 5: Add Inbound Rule to Security Group
echo "Adding inbound rule to security group for port $PORT..."
aws ec2 authorize-security-group-ingress \
    --group-id $SECURITY_GROUP_ID \
    --protocol tcp \
    --port $PORT \
    --cidr 0.0.0.0/0
echo "Inbound rule added successfully."

# Step 6: Run ECS Task
echo "Running ECS task in cluster $CLUSTER_NAME..."
aws ecs run-task \
    --cluster $CLUSTER_NAME \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={
        subnets=[\"$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query 'Subnets[0].SubnetId' --output text)\"],
        securityGroups=[\"$SECURITY_GROUP_ID\"],
        assignPublicIp=\"ENABLED\"}" \
    --task-definition $TASK_DEFINITION_NAME
echo "Task is running in cluster $CLUSTER_NAME."

echo "ECS setup completed successfully."
