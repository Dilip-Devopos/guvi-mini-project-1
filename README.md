Brain Tasks App - CI/CD Deployment on AWS with Kubernetes
This document outlines the end-to-end deployment process of the Brain Tasks React application using AWS services like ECR, EKS, CodePipeline, CodeBuild, and CodeDeploy, including monitoring with CloudWatch.
📌 Project Overview
This project automates the deployment of a production-ready React application using containerization, continuous integration, and delivery mechanisms on AWS. It covers Docker image builds, ECR image hosting, EKS deployment, and end-to-end pipeline integration with CodePipeline and monitoring with CloudWatch.
📖 Step-by-Step Process
Step 1: Clone and Build the React Application
Clone the React application and build it for production:

git clone https://github.com/Vennilavan12/Brain-Tasks-App.git
cd Brain-Tasks-App
npm install
npm run build

The production files will be placed in the `/dist` directory.
Step 2: Dockerize the Application
Use the following Dockerfile to serve the React app using NGINX:
FROM public.ecr.aws/nginx/nginx:1.25
RUN rm -rf /usr/share/nginx/html/*
COPY /dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

Build and tag the Docker image:
docker build -t dilip/guvi:latest .

Step 3: Push Docker Image to Amazon ECR
Login to ECR and push your image:
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
docker tag dilip/guvi:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/dilip/guvi:<build-number>
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/dilip/guvi:<build-number>

Step 4: Deploy on Amazon EKS
Use the following `deployment.yml` and `service.yml` to deploy your app:
- Deployment with 2 replicas and readiness/liveness probes
- Service type: LoadBalancer to expose externally
Run the deployment using kubectl:
kubectl apply -f deployment.yml
kubectl apply -f service.yml

Step 5: Setup CodePipeline for CI/CD
CodePipeline is configured to:

- Source: GitHub Repository
- Build: CodeBuild (defined via buildspec.yml)
- Deploy: CodeDeploy (defined via appspec.yml + deploy.sh)

This allows end-to-end automation from code push to EKS deployment.
Step 6: Monitor with CloudWatch & Fluent Bit
Pod logs from EKS are shipped to CloudWatch using Fluent Bit. EC2 system and CodeDeploy logs are sent using the CloudWatch agent.
Fluent Bit Helm Chart Install:
helm repo add aws-observability https://aws.github.io/eks-charts
helm upgrade --install aws-for-fluent-bit aws-observability/aws-for-fluent-bit \
  --namespace amazon-cloudwatch \
  --create-namespace \
  --set cloudWatch.enabled=true \
  --set cloudWatch.region=us-east-1 \
  --set cloudWatch.logGroupName=/aws/eks/pod-logs \
  --set serviceAccount.create=true

📸 Screenshots (To be Added)
- CodePipeline overview
- CodeBuild logs
- CodeDeploy logs
- Kubernetes `kubectl get all` output
- CloudWatch log stream view
👨‍💻 Author & Final Notes
Dilip
DevOps Engineer
GitHub: https://github.com/Dilip-Devopos
Ensure EC2 instances and EKS nodes have necessary IAM permissions and open ports.
