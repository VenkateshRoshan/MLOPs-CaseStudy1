#! /bin/bash

#This will initialize the azure resource group and environment
#Only needs to be ran once per azure environment

az group create --name CS553 --location eastus

az containerapp env create \
  --name managedenvironment-cs553 \
  --resource-group CS553 \
  --location eastus