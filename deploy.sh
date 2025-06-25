#######################################################################################################################################################################################
# Author: Dilip
# Date: 2025-06-25
# Description: This script deploys the Brain Tasks application to a Kubernetes cluster.
# It checks if the deployment and service already exist, deletes them if they do, and then applies the new configurations.
# Usage: Run this script in the directory where your deployment and service YAML files are located.
# Prerequisites: Ensure you have kubectl installed and configured to access your Kubernetes cluster.
# Note: This script assumes that the deployment and service YAML files are named 'deployment.yml' and 'service.yml' respectively.
# Ensure you have the necessary permissions to create, delete, and apply resources in the specified namespace.
# The script uses 'set -e' to exit on any error and 'set -x' to print commands for debugging purposes.
# Make sure to run this script with appropriate permissions, typically as a user with access to the Kubernetes cluster.
# The script will check for the existence of the deployment and service, delete them if they exist, and then apply the new configurations.
# If the service does not exist, it will create it; if it does exist, it will skip the apply step for the service.
# The script uses a default namespace.
#######################################################################################################################################################################################
# deploy.sh
# This script deploys the Brain Tasks application to a Kubernetes cluster.
# It checks if the deployment and service already exist, deletes them if they do, and then applies the new configurations.
########################################################################################################################################################################################
#!/bin/bash
set -e  # exit on any error
set -x  # print commands (debug)

# Go to the directory where deployment files were copied
cd /home/ubuntu

# Set the namespace if needed
NAMESPACE=default

# Define your deployment and service names
DEPLOYMENT_NAME=brain-tasks-deployment
SERVICE_NAME=brain-tasks-service

# Define your YAML paths
DEPLOYMENT_YAML=deployment.yml
SERVICE_YAML=service.yml

echo "Checking if deployment '$DEPLOYMENT_NAME' exists..."
if kubectl get deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE" &> /dev/null; then
    echo "Deployment '$DEPLOYMENT_NAME' exists. Deleting it..."
    kubectl delete deployment "$DEPLOYMENT_NAME" -n "$NAMESPACE"
    sleep 5  # Optional: wait for cleanup
else
    echo "Deployment '$DEPLOYMENT_NAME' does not exist. Skipping delete."
fi

echo "Applying deployment YAML..."
kubectl apply -f "$DEPLOYMENT_YAML" -n "$NAMESPACE"

echo "Checking if service '$SERVICE_NAME' exists..."
if kubectl get service "$SERVICE_NAME" -n "$NAMESPACE" &> /dev/null; then
    echo "Service '$SERVICE_NAME' exists. Skipping apply."
else
    echo "Service '$SERVICE_NAME' does not exist. Applying service YAML..."
    kubectl apply -f "$SERVICE_YAML" -n "$NAMESPACE"
fi
