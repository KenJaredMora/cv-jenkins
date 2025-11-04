# Automated CI/CD Pipeline for Vite App

This project demonstrates an automated CI/CD pipeline that deploys a Vite TypeScript application to AWS EC2 using GitHub Actions and Terraform.

## Tech Stack

**Application:**

- Vite
- TypeScript

**Infrastructure & Pipeline:**

- AWS EC2 (free tier)
- Terraform (infrastructure provisioning)
- GitHub Actions (CI/CD pipeline)

## Architecture

When a pull request is merged to the `main` branch, the pipeline automatically:

1. Builds the Vite application
2. Creates a deployment archive
3. Deploys to the EC2 instance via SSH
4. Serves the updated application

## Setup Instructions

### 1. Infrastructure Setup

1. Define your `terraform/terraform.tfvars`:

   ```hcl
   # Make sure the allowed_http_cidr includes the IP of machines you plan to test from
   allowed_http_cidr = ["your.ip.address/32"]
   ```

2. Execute Terraform to provision AWS infrastructure:

   ```bash
   cd terraform
   terraform apply
   ```

3. Wait for deployment to complete and note the EC2 public IP from the outputs.

### 2. GitHub Repository Configuration

Set up the following GitHub Actions secrets in your repository:

- `EC2_HOST`: The public IP address of your EC2 instance (from Terraform output)
- `EC2_USER`: SSH username (typically `ubuntu` for Ubuntu AMI)
- `DEPLOY_SSH_PRIVATE_KEY`: Private SSH key for EC2 access

### 3. Testing the Pipeline

1. Make any changes to the `my-vite-app` directory
2. Commit and push changes to trigger the pipeline
3. Access your deployed application at `http://[EC2_IP]`
4. See your changes live!

## Project Structure

```text
├── .github/workflows/deploy.yml    # GitHub Actions workflow
├── my-vite-app/                    # Vite TypeScript application
├── scripts/deploy.sh               # Deployment script for EC2
├── terraform/                      # Infrastructure as Code
└── README.md                       # This file
```

## Features

- **Automated Deployment**: Triggers on main branch changes
- **Free Tier Compatible**: Uses AWS free tier resources
- **SSH Security**: Secure deployment using SSH keys
- **Build Optimization**: Efficient build and deployment process
