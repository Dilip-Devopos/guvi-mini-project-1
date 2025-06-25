
# Brain Tasks App - CI/CD Deployment on AWS with Kubernetes

## 📌 Project Overview

This project automates the deployment of a production-ready React application using containerization, continuous integration, and delivery mechanisms on AWS. It covers Docker image builds, ECR image hosting, EKS deployment, and end-to-end pipeline integration with CodePipeline and monitoring with CloudWatch.

---

## 🧠 Application

- **Repository**: [Brain Tasks App](https://github.com/Vennilavan12/Brain-Tasks-App.git)
- **Port**: Runs on `3000` (exposed on port `80` via NGINX)
- **Frontend**: React
- **Build Output**: `/dist` directory copied to NGINX container

---

## 🚢 Dockerization

- **Base Image**: `public.ecr.aws/nginx/nginx:1.25`
- **Custom Dockerfile** removes default HTML and serves app from `/usr/share/nginx/html`
- **Exposed Port**: `80`

```Dockerfile
FROM public.ecr.aws/nginx/nginx:1.25
RUN rm -rf /usr/share/nginx/html/*
COPY /dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---

## 🐳 Amazon ECR

- Created private ECR repository: `dilip/guvi`
- Tagged and pushed Docker images via CodeBuild
- Image naming: `380561001200.dkr.ecr.us-east-1.amazonaws.com/dilip/guvi:<build-number>`

---

## ☸️ Kubernetes on AWS EKS

- **Deployment File**: `deployment.yml`
- **Service File**: `service.yml`
- **Namespace**: `default`
- **Probes**: Readiness and Liveness configured
- **Resources**: Requests and limits set for CPU and memory

```bash
kubectl apply -f deployment.yml
kubectl apply -f service.yml
```

✅ **Add your LoadBalancer DNS/ARN here**

---

## ⚙️ AWS CodePipeline Setup

### 1. Source
- GitHub repository connected to trigger pipeline

### 2. Build – CodeBuild
- **File**: `buildspec.yml`
- Installs Trivy for image scanning
- Builds and tags Docker image
- Pushes to ECR
- Updates `deployment.yml` with latest image tag
- Pushes updated file back to GitHub
- Sends SNS notification on success

### 3. Deploy – CodeDeploy
- **AppSpec File**: `appspec.yml`
- Copies all files to `/home/ubuntu` on EC2 instance
- Executes `deploy.sh` to apply Kubernetes resources

---

## 🛠️ Scripts Overview

### `deploy.sh`

- Checks for existing K8s deployment/service
- Deletes old deployment if present
- Applies new deployment YAML
- Creates service only if it doesn’t already exist

### `appspec.yml`

- Copies codebase to EC2 instance
- Runs `deploy.sh` under `ubuntu` user

---

## 📊 Monitoring with CloudWatch

### EC2 Log Monitoring:

- Installed **Amazon CloudWatch Agent**
- Monitors:
  - `/var/log/syslog`
  - CodeDeploy logs (`codedeploy-agent-deployments.log`)
- Log groups:
  - `/ec2/syslog`
  - `/ec2/codedeploy`

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
- CodeBuild logs and success
- CodeDeploy history
- Kubernetes dashboard or `kubectl get all` output
- CloudWatch log group snapshots

---

## 👨‍💻 Author

**Dilip**  
DevOps Engineer  
GitHub: [Dilip-Devopos](https://github.com/Dilip-Devopos)

---

## 📌 Notes

- Ensure EC2 instance has:
  - CodeDeploy agent installed
  - CloudWatch agent installed
  - IAM role with EKS + ECR + SNS + CodeDeploy permissions
- All traffic allowed in EC2/EKS Security Group
- Kubernetes context properly configured in EC2
