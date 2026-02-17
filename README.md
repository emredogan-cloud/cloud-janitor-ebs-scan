# 📉 Cloud Janitor – Containerized EBS Scanner  
> **Serverless AWS cost visibility automation using Terraform & Docker**

[![Cloud Janitor CI](https://github.com/emredogan-cloud/cloud-janitor-ebs-scan/actions/workflows/main.yaml/badge.svg)](https://github.com/emredogan-cloud/cloud-janitor-ebs-scan/actions/workflows/main.yaml)

![Cloud Janitor Architecture](docs/cloud-janitor.png)

---

## 📖 Project Description

**Cloud Janitor** is a fully serverless AWS automation tool designed to identify **orphaned EBS volumes** (volumes in `available` state), estimate their **monthly storage cost**, and deliver a consolidated report to **Discord**.

Unlike traditional Lambda deployments, this project is **containerized using Docker**. The infrastructure and the container build process are fully managed by **Terraform**, ensuring a consistent runtime environment and eliminating dependency issues.

### Key Features & Skills Demonstrated

- ✅ **Infrastructure as Code:** Full lifecycle management with Terraform  
- ✅ **Containerized Lambda:** Packaged as a Docker image (ECR) for consistent execution  
- ✅ **Automated Build Pipeline:** Terraform builds & pushes the image to ECR automatically  
- ✅ **FinOps Mindset:** Automated cost estimation and visibility  
- ✅ **Multi-Region Support:** Scans orphaned resources across multiple AWS regions  
- ✅ **Least Privilege Security:** Granular IAM roles and policies  

---

## ⚙️ High-Level Flow

1. **Terraform** provisions the ECR repository and IAM roles.
2. **Terraform (local-exec)** builds the Docker image locally and pushes it to **Amazon ECR**.
3. **Terraform** deploys the **AWS Lambda** function using the image from ECR.
4. **EventBridge Scheduler** triggers the Lambda container daily at **09:00 (Europe/Istanbul)**.
5. **AWS Lambda**:
   - Queries EC2 APIs for orphaned EBS volumes using `boto3`
   - Estimates monthly storage cost based on volume type and size
   - Aggregates results into a structured report
6. **Discord Webhook** receives the formatted inventory and cost report.

---

## 🏗 Architecture Components

| Component | Description |
|---|---|
| **AWS Lambda** | Runs as a Docker Container (Python 3.11), stateless execution |
| **Amazon ECR** | Stores the Docker container image securely |
| **EventBridge Scheduler** | Cron-based, timezone-aware scheduler |
| **IAM** | Least-privilege roles; read-only EC2 access and log write permissions |
| **Terraform** | Manages infrastructure, ECR repos, and Docker build/push automation |

---

## 🛠 Prerequisites

Before deploying, ensure you have the following installed and configured:

- **AWS CLI** (configured via `aws configure`)
- **Terraform** (v1.5+ recommended)
- **Docker Desktop** (must be running for image building)
- A **Discord Webhook URL**
- AWS credentials with permissions to create ECR, Lambda, IAM, EventBridge Scheduler, and CloudWatch Logs resources

---

## 🚀 Deployment Guide

### 1) Clone the Repository

```bash
git clone https://github.com/emredogan-cloud/cloud-janitor-ebs-scan.git
cd cloud-janitor-ebs-scan
```

### 2) Configure Secrets

⚠️ **Security note:** Never commit secrets to version control.

Create a `terraform.tfvars` file inside the `terraform/` directory:

```hcl
# terraform/terraform.tfvars
lambda_vars = {
  DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/YOUR_WEBHOOK_HERE"
  REGIONS             = "us-east-1,eu-central-1"
}
```

> Tip: Add `terraform/terraform.tfvars` to your `.gitignore` if it isn’t already ignored.

### 3) Initialize & Deploy

Switch to the `terraform/` directory and apply the configuration (ensure Docker is running):

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Type `yes` when prompted. Terraform will automatically build the Docker image, push it to ECR, and deploy the Lambda function.

---

## 🧪 Manual Test (Optional)

You don’t have to wait for the scheduled time. You can manually invoke the Lambda function to verify Discord notifications:

- **AWS Console:** Lambda → your function → *Test*
- **AWS CLI:**
  ```bash
  aws lambda invoke --function-name <YOUR_FUNCTION_NAME> out.json
  cat out.json
  ```

---

## 🧹 Cleanup (Optional)

To remove all provisioned resources:

```bash
cd terraform
terraform destroy
```

---

## 👨‍💻 Author

**Emre Doğan**  
Aspiring AWS Solutions Architect

- GitHub: **emredogan-cloud**
- LinkedIn: **Emre Doğan**
