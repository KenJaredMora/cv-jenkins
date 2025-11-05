# 🚀 Automated CI/CD Pipeline for Vite App

This project implements an automated CI/CD pipeline for deploying a Vite + TypeScript application to AWS EC2, using Jenkins and Terraform.

It's a fully self-hosted alternative to the GitHub Actions version — giving you control over every build, deployment, and infrastructure step.

## 🧩 Tech Stack

**Application:**

- Vite
- TypeScript

**Infrastructure & Pipeline:**

- AWS EC2 (free tier)
- Terraform (infrastructure provisioning)
- Jenkins – (CI/CD pipeline) Continuous Integration & Deployment Server
- Nginx – Web server on target EC2 instance

## 🏗️ Architecture

This setup uses two EC2 instances:

| Instance | Purpose | Typical User | Port |
|----------|---------|--------------|------|
| jenkins-controller | Hosts Jenkins CI/CD server | ubuntu | 8080 |
| cv-jenkins-instance | Hosts deployed Vite app | deploy | 80 |

When a pull request is merged to the `main` branch on GitHub, the pipeline automatically:

1. Jenkins automatically pulls the latest code (This can be configured to run every minute, hour, day, etc.)
2. Jenkins builds the app using NodeJS
3. The pipeline packages the build artifact (vite-build.tar.gz)
4. Jenkins connects to the app EC2 instance via SSH
5. The deploy script updates /var/www/html via symlink release
6. Nginx reloads and serves the new version

## ⚙️ Setup Instructions

### 1. Infrastructure Setup (Terraform)

1. Define your `terraform/terraform.tfvars`:

   ```hcl
   # Make sure the allowed_http_cidr includes the IP of machines you plan to test from
   allowed_http_cidr = ["your.ip.address/32"]
   ```

2. Execute Terraform to provision AWS infrastructure:

   ```bash
   cd terraform
   terraform init
   terraform plan
   terraform apply
   ```

3. Terraform provisions:
      One EC2 for Jenkins Controller
      One EC2 for the Application

4. After completion (Record both public IPs).

### 2. Jenkins Configuration

#### Install Required Plugins

Navigate to **Manage Jenkins → Plugins → Available plugins** and install:

- **Git** - Source code management
- **NodeJS** - Build environment for Vite app
- **SSH Agent** - Secure deployment to target EC2
- **Pipeline** - Jenkins pipeline support

#### Configure Build Tools

1. Go to **Manage Jenkins → Tools → NodeJS Installations**
2. Click **Add NodeJS** and configure:
   - **Name:** `node20`
   - **Version:** `20.19.x` (or latest LTS)
   - **Global npm packages to install:** Leave empty

#### Add SSH Credentials

1. Navigate to **Manage Jenkins → Credentials → System → Global credentials**
2. Click **Add Credentials** and configure:

| Field | Value | Description |
|-------|-------|-------------|
| Kind | SSH Username with private key | Secure SSH access |
| ID | `deploy` | Referenced in Jenkinsfile |
| Username | `deploy` | EC2 user for app instance |
| Private Key | Enter directly | Paste contents of `~/.ssh/deploy_jenkins_app` |

#### Create Jenkins Pipeline Job

1. **New Item → Pipeline → Enter name: `cv-jenkins-pipeline`**
2. Configure the pipeline:
   - ✅ **GitHub project:** Enter your repository URL
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/KenJaredMora/cv-jenkins.git`
   - **Branch Specifier:** `*/main`
   - **Script Path:** `Jenkinsfile`

3. **Save** and click **Build Now** to test

#### Expected Build Output

```bash
🚀 Starting deployment...
📦 Release: /var/www/releases/20251105010447_deploy
✅ Deployment successful!
🌐 Application is running at: http://34.205.171.188
```

**Verify deployment:** Visit `http://[YOUR_EC2_IP]` to see your live application.

## 📁 Project Structure

```bash
.
├── Jenkinsfile                     # Jenkins pipeline definition
├── scripts/
│   └── deploy.sh                   # EC2 deployment automation
├── my-vite-app/                    # Vite TypeScript application
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── vite.config.ts
├── terraform/                      # Infrastructure as Code
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── docs/                           # Additional documentation
└── README.md
```

## 🌟 Key Features

✅ **Self-hosted CI/CD** with complete infrastructure control  
✅ **Multi-instance architecture** (separated Jenkins controller and app server)  
✅ **Secure SSH deployments** with dedicated user and key management  
✅ **Automated NodeJS builds** with Vite optimization  
✅ **Zero-downtime deployments** via symlink-based releases  
✅ **Nginx auto-reload** for immediate traffic routing  
✅ **Build artifact versioning** with timestamp-based releases  
✅ **Infrastructure as Code** for reproducible environments  

## 🔒 Security Best Practices

### Network Security

- **Restrict SSH access (port 22)** to Jenkins controller IP only
- **Limit Jenkins UI (port 8080)** to your personal/office IP ranges
- **Use security groups** to enforce least-privilege access

### Authentication & Keys

- **Rotate SSH keys** every 90 days minimum
- **Use dedicated service accounts** (`deploy` user) for automation
- **Store credentials** securely in Jenkins credential store
- **Enable 2FA** on Jenkins admin accounts

### Infrastructure Hardening

- **Regular security updates** on both EC2 instances
- **Monitor access logs** for suspicious activity
- **Use HTTPS + reverse proxy** for Jenkins (production recommendation)
- **Implement backup strategies** for critical configurations

## 🛠️ Troubleshooting

### Common Build Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Node version mismatch | Incompatible NodeJS version | Update Jenkins NodeJS tool to 20.19.x+ |
| SSH connection failed | Wrong credentials or IP | Verify deploy key and security groups |
| Build artifacts missing | Build step failure | Check Jenkins console logs for npm errors |
| Nginx not reloading | Permission issues | Ensure deploy user has sudo access for nginx |

### Debugging Commands

```bash
# Check Jenkins build logs
tail -f /var/log/jenkins/jenkins.log

# Verify deployment on app server
ssh deploy@[APP_EC2_IP] "ls -la /var/www/releases/"

# Test Nginx configuration
sudo nginx -t && sudo systemctl reload nginx

# Monitor deployment in real-time
ssh deploy@[APP_EC2_IP] "tail -f /var/log/nginx/access.log"
```

## 🚀 Performance Optimizations

### Build Speed

- **Use npm/yarn caching** in Jenkins workspace
- **Parallel build stages** for larger applications
- **Incremental builds** to avoid rebuilding unchanged code

### Deployment Efficiency

- **Compress artifacts** before transfer (already implemented with tar.gz)
- **Keep only last 5 releases** to manage disk space
- **Pre-warm application** after deployment

## 📈 Monitoring & Observability

### Recommended Monitoring Stack

- **Jenkins build notifications** via Slack/email webhooks
- **Application health checks** with custom endpoints
- **Server monitoring** using CloudWatch or Prometheus
- **Log aggregation** for centralized debugging

### Key Metrics to Track

- Build duration and success rate
- Deployment frequency and rollback rate
- Application response time and error rate
- Infrastructure resource utilization

## 🔄 Advanced Usage

### Webhook Integration

Set up GitHub webhooks for automatic triggering:

```bash
# GitHub webhook URL
http://[JENKINS_IP]:8080/github-webhook/
```

### Multi-Environment Support

Extend the pipeline for staging and production:

```groovy
// Jenkinsfile example for multiple environments
when {
    anyOf {
        branch 'main'       // Production
        branch 'develop'    // Staging
    }
}
```

### Rollback Strategy

Quick rollback to previous release:

```bash
# On app server
cd /var/www && sudo ln -sfn releases/[PREVIOUS_RELEASE] html
sudo systemctl reload nginx
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Test changes in a separate environment
4. Commit with conventional commits: `git commit -m 'feat: add amazing feature'`
5. Push and create a Pull Request

## 📚 Additional Resources

- [Jenkins Pipeline Documentation](https://www.jenkins.io/doc/book/pipeline/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Vite Build Optimization](https://vitejs.dev/guide/build.html)
- [Nginx Configuration Best Practices](https://nginx.org/en/docs/)

**💡 Pro Tip:** For production environments, consider implementing blue-green deployments and automated testing stages in your pipeline.
