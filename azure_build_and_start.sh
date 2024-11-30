#! /bin/bash

# Run the container on Azure
az containerapp create \
  --name cs553-casestudy4-group13 \
  --resource-group CS553 \
  --environment managedenvironment-cs553 \
  --image venkateshroshan/mlops-cs4:latest \
  --ingress external \
  --target-port 7860
  
# Get the URL
az containerapp show \
  --name cs553-casestudy4-group13 \
  --resource-group CS553 \
  --query properties.configuration.ingress.fqdn