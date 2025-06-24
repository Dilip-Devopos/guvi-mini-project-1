#!/bin/bash

cd /home/ubuntu

echo "Applying Kubernetes manifests..."
kubectl delete deployment brain-tasks-deployment
