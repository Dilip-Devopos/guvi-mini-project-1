#!/bin/bash

cd /home/ubuntu

echo "Applying Kubernetes manifests..."
kubectl apply -f deployment.yml
kubectl apply -f service.yml

