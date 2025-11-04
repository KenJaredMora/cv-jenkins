variable "region" { type = string }

variable "aws_profile" {
  description = "The AWS profile to use for authentication"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to SSH (22) for admin access. e.g., 203.0.113.25/32"
  type        = list(string)
}

variable "github_actions_ssh_cidrs" {
  description = "GitHub Actions runner IP ranges for SSH access. Updated from GitHub's Meta API: https://api.github.com/meta"
  type        = list(string)
  default = [
    # Core GitHub Actions ranges (most commonly used)
    "4.148.0.0/16", # Primary GitHub Actions ranges
    "4.149.0.0/18",
    "4.150.0.0/18",
    "4.151.0.0/16",
    "4.152.0.0/15",
    "4.154.0.0/15",
    "4.156.0.0/15",
    "13.64.0.0/16", # Additional Azure ranges for GitHub Actions
    "13.65.0.0/16",
    "20.1.128.0/17", # More GitHub Actions IP blocks
    "20.3.0.0/16",
    "52.224.0.0/16", # Extended GitHub Actions coverage
    "52.225.0.0/17"
  ]
}

variable "admin_public_key_path" {
  description = "Path to the public key file for the admin user (ec2-user)."
  type        = string
}

variable "admin_pem_file_path" {
  description = "Path to the private key file for the admin user (ec2-user)."
  type        = string
}

variable "deploy_public_key" {
  description = "Public key string used by the 'deploy' user for CI/CD (ssh-ed25519 AAAA... or ssh-rsa AAAA...)."
  type        = string
}

variable "module_prefix" {
  description = "The prefix for the resources."
  type        = string
  default     = "vite-app-demo"
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created."
  type        = string
}

variable "subnet_id" {
  description = "The Subnet ID where the instance will be launched."
  type        = string
  default     = null
}

variable "allowed_http_cidr" {
  description = "The CIDR blocks allowed to access HTTP (port 80)."
  type        = list(string)
}

variable "instance_type" {
  description = "The type of instance to use."
  type        = string
  default     = "t3.micro"
}

variable "iam_instance_profile" {
  type    = string
  default = null
}
