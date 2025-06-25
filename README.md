# Brain Tasks Reactjs Application - CI/CD Deployment on AWS with EKS-Cluster

## 👨‍💻 Author

**Dilip** 
GitHub: [Dilip-Devopos](https://github.com/Dilip-Devopos/guvi-mini-project-1)

---

## CLick to visit Deployment:

        http://abb59c4b452064c768a9c0975c9ced80-1446271263.us-east-1.elb.amazonaws.com
        
## 📌 Project Overview

This project automates the deployment of a production-ready Reactjs application using containerization, continuous integration, and delivery mechanisms on AWS. It covers Docker image builds, image scanning , ECR image hosting, EKS deployment, and end-to-end pipeline integration with CodePipeline, CodeBuild, CodeDeploy  and monitoring with CloudWatch.

## Pipeline WorkFlow

 CodePush -> github -> CodePipeline -> CodeBuild -> SNS-Email -> CodeDeploy -> EC2-Instances (ec2-instance via access eks cluster and deploy the deployment and service) -> EKS-Cluster -> CloudWatch

 🔄 CI/CD Workflow
      1. Code Push
           Developers push code to the GitHub repository (Brain-Tasks-App). This triggers the CI/CD pipeline.
      2. AWS CodePipeline
          Source Stage: Listens for changes on GitHub.
          Build Stage (CodeBuild): Executes buildspec.yml, which:
          Installs Trivy for vulnerability scanning.
          Builds and tags Docker image.
          Pushes the image to Amazon ECR.
          Automatically updates deployment.yml with new image tag.
          Commits and pushes changes back to GitHub.
          Sends an SNS notification on success.
      3. Kubernetes Deployment (EKS)
          The script deploy.sh:
          Removes any existing deployment.
          Applies deployment.yml.
          If the service running skip the service creation. if not craet the service.
      4. Monitoring & Logging
         EC2 Logs: CloudWatch Agent monitors syslog and CodeDeploy logs, storing them in CloudWatch
         EKS Pod Logs: Fluent Bit (deployed via Helm) forwards logs to /aws/eks/pod-logs in CloudWatch

    

Deploy Stage (CodeDeploy): Uses appspec.yml to copy files to an EC2 host and runs deploy.sh to apply Kubernetes updates via kubectl.
---

## 🧠 Application

- **Repository**: [Brain Tasks App](https://github.com/Vennilavan12/Brain-Tasks-App.git)
- **Port**: Runs on 3000 (exposed on port 80 via NGINX)
- **Frontend**: Reactjs
- **Build Output**: /dist directory copied to NGINX container

---

## 🚢 Dockerization

- **Base Image**: public.ecr.aws/nginx/nginx:1.25
- **Custom Dockerfile** removes default HTML and serves app from /usr/share/nginx/html
- **Exposed Port**: 80

Dockerfile
FROM public.ecr.aws/nginx/nginx:1.25
RUN rm -rf /usr/share/nginx/html/*
COPY /dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

---

## 🐳 Amazon ECR

- Created private ECR repository: dilip/guvi
- Tagged and pushed Docker images via CodeBuild
- Image naming: 380561001200.dkr.ecr.us-east-1.amazonaws.com/dilip/guvi:<build-number> -> Build-Number Dynamic

---

## ☸️ Kubernetes on AWS EKS

- **Deployment File**: deployment.yml
- **Service File**: service.yml
- **Namespace**: default
- **Probes**: Readiness and Liveness configured
- **Resources**: Requests and limits set for CPU and memory

```bash
kubectl apply -f deployment.yml
kubectl apply -f service.yml
```

---

## ⚙️ AWS CodePipeline Setup

### 1. Source
- GitHub repository connected to trigger pipeline

### 2. Build – CodeBuild
- **File**: buildspec.yml
- Installs Trivy for image scanning
- Builds and tags Docker image
- Pushes to ECR
- Updates deployment.yml with latest image tag
- Pushes updated file back to GitHub
- Sends SNS notification on success

### 3. Deploy – CodeDeploy
- **AppSpec File**: appspec.yml
- Copies all files to /home/ubuntu on EC2 instance
- Executes deploy.sh to apply Kubernetes resources

---

## 🛠️ Scripts Overview

### `deploy.sh`

- Checks for existing K8s deployment/service
- Deletes old deployment if present
- Applies new deployment YAML
- Creates service only if it doesn’t already exist

### `appspec.yml`

- Copies codebase to EC2 instance
- Runs deploy.sh under ubuntu user

---

## 📊 Monitoring with CloudWatch

### EC2 Log Monitoring:

- Installed **Amazon CloudWatch Agent**
- Monitors:
  - /var/log/syslog
  - CodeDeploy logs (`codedeploy-agent-deployments.log`)
- Log groups:
  - /ec2/syslog
  - /ec2/codedeploy

### EKS Pod Logs:

- Installed Fluent Bit via Helm:

```bash
helm repo add aws-observability https://aws.github.io/eks-charts
helm upgrade --install aws-for-fluent-bit aws-observability/aws-for-fluent-bit   --namespace amazon-cloudwatch   --create-namespace   --set cloudWatch.enabled=true   --set cloudWatch.region=us-east-1   --set cloudWatch.logGroupName=/aws/eks/pod-logs   --set serviceAccount.create=true
```

- Pod logs are forwarded to `/aws/eks/pod-logs` group in CloudWatch.

---

## 📂 Folder Structure

```bash
├── appspec.yml
├── buildspec.yml
├── deploy.sh
├── deployment.yml
├── service.yml
├── Dockerfile
├── dist/
└── README.md
```

---

## ✅ Deployment Verification

- Run `kubectl get all` to verify resources
- Access the app using the LoadBalancer DNS name

---

## 📸 Screenshots (To be Added)

- AWS CodePipeline stages
     ![image](https://github.com/user-attachments/assets/c341b2c8-28b1-417c-a807-2ce577a0958d)
     
- CodeBuild logs and success
      ![image](https://github.com/user-attachments/assets/25adbc6a-8774-4624-851c-4da43f48a90b)
      ![image](https://github.com/user-attachments/assets/6cea40ec-1bcb-4302-ae11-4748f4b76e62)
      
- CodeDeploy history
      ![image](https://github.com/user-attachments/assets/454e3db9-b351-486f-aecb-e9ea7545f2dc)
      ![image](https://github.com/user-attachments/assets/0ec2b100-5045-4496-981f-9fc5ff7cb0a3)
      
- Kubernetes dashboard
      ![image](https://github.com/user-attachments/assets/2964d000-0926-48ff-9466-8eed4da4f059)
      ![image](https://github.com/user-attachments/assets/eb86aace-a62e-4fb6-9414-ef9ec667eb2e)
  
- LoadBalancer  
      ![image](https://github.com/user-attachments/assets/f7276763-d54f-4b68-8d2a-2e2a87fb604f)

- EC2-Inastances
      ![image](https://github.com/user-attachments/assets/67bc79ca-69b6-4462-ba9d-0cb60d75d8a6)

- Output
      ![image](https://github.com/user-attachments/assets/d14dd4f4-d208-420e-8643-5e819a1931ad)

- Aws- ECR Registry
      ![image](https://github.com/user-attachments/assets/782518f6-8819-451c-a6ae-d91929a11532)

- CloudWatch
      ![image](https://github.com/user-attachments/assets/8887196c-95ef-48a3-bac0-76b0ee55d773)

- Email (Sucess and Failuer)
      ![image](https://github.com/user-attachments/assets/92e9a0db-0924-417a-beda-353c5fd8a7d1)
      ![image](https://github.com/user-attachments/assets/e7f7cf78-6aa3-4f96-bda8-5171ef9ca38d)
      ![image](https://github.com/user-attachments/assets/2a3441e3-268e-4e2b-8512-9ac4e8a2cb7c)

- Commands to verify
  
    kubectl get pods
  
    kubectl get svc
  
    sudo systemctl status amazon-cloudwatch-agent
  
    kubectl logs aws-for-fluent-bit-95tvt -n amazon-cloudwatch
  
    eksctl create cluster --name guvi --region us-east-1 --node-type t2.medium
  
    aws eks --region us-east-1 update-kubeconfig --name guvi
  
    cat /opt/codedeploy-agent/deployment-root/deployment-logs/codedeploy-agent-deployments.log

---

