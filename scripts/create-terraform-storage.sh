#!/bin/sh

RESOURCE_GROUP_NAME="fdk-storage-rg"
STORAGE_ACCOUNT_NAME="fdkstorage"
# STORAGE_ACCOUNT_KEY="0auSWsK0LLAquVmVlAe8ljF+ZP0LaUUuOErBIFrDwhsyEGGi9+Ur+gYWQaPqPdtYZ1XoqUMwyjlM+AStbiZxiA=="
#STORAGE_ACCOUNT_KEY="lbtHIB1bnT8sPyW47baXjmcHmQ6Alhehcr+wBDd7oac7e9T/u2ODnyrzJ6Pta1eJ0c46yeAR9uBJ+AStoUOU+A=="

# Create Resource Group
az group create -l westeurope -n $RESOURCE_GROUP_NAME

# Create Storage Account
az storage account create -n $STORAGE_ACCOUNT_NAME -g $RESOURCE_GROUP_NAME -l westeurope --sku Standard_LRS

STORAGE_ACCOUNT_KEY=$(az storage account show-connection-string -g $RESOURCE_GROUP_NAME --name fdkstorage --query connectionString -otsv| cut -d ";" -f4 | sed "s/AccountKey=//")

# Create Storage Account blob
az storage container create  --name tfstate --account-name $STORAGE_ACCOUNT_NAME --account-key $STORAGE_ACCOUNT_KEY