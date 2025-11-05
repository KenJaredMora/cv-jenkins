#!/bin/bash
# EC2 User Data Script for Vite CI/CD Pipeline
# This script runs once when the EC2 instance first boots up
# It prepares the server for automated deployments from GitHub Actions

# Exit on any error, treat unset variables as errors, fail on pipe errors
# Note: set -euo pipefail enables strict error handling:
# -e: Exit immediately if any command fails (non-zero exit code)
# -u: Treat unset/undefined variables as errors and exit
# -o pipefail: Make pipes fail if any command in the pipe fails (not just the last one)
set -euo pipefail

# Configuration variables
SSH_PUBKEY="${ssh_pubkey}"        # Public key injected by Terraform templatefile()
DEPLOY_USER="deploy"              # User that GitHub Actions will use to deploy
WEBROOT="/var/www/html"           # Where nginx serves files from (will be a symlink)
RELEASES_DIR="/var/www/releases"  # Directory storing all deployment versions
CURRENT_LINK="$WEBROOT"           # Symlink target for atomic deployments

# ---------- System update & nginx ----------
# Update system packages and install nginx web server
sudo yum -y update

# Install nginx from Amazon Linux Extras and start it
sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable --now nginx  # Enable auto-start on boot and start now

# ---------- Create deploy user ----------
# Create a dedicated user for CI/CD deployments (security best practice)
if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
  sudo useradd -m -s /bin/bash "$DEPLOY_USER"  # Create user with home directory and bash shell
fi

# Set up SSH access for the deploy user
sudo install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" /home/$DEPLOY_USER/.ssh  # Create .ssh dir with secure permissions
# sudo install - Uses the install command (more robust than mkdir for setting permissions atomically)
# -d - Creates a directory instead of copying files
# -m 700 - Sets permissions to 700 (read/write/execute for owner only, no access for group/others)
# -o "$DEPLOY_USER" - Sets the owner to the deploy user
# -g "$DEPLOY_USER" - Sets the group to the deploy user's group
# /home/$DEPLOY_USER/.ssh - The target directory path
echo "$SSH_PUBKEY" | sudo tee /home/$DEPLOY_USER/.ssh/authorized_keys              # Add public key for SSH access
sudo chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh/authorized_keys       # Set proper ownership
sudo chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys                             # Secure permissions (owner read/write only)

# ---------- Sudo permissions for deploy ----------
# Grant deployment-specific sudo permissions to deploy user
# Allows all commands needed for CI/CD deployment operations
# Note: Using /etc/sudoers.d/99-deploy instead of /etc/sudoers for modularity and safety:
# - Keeps custom rules separate from system defaults
# - Prevents corruption of main sudoers file
# - Easier to manage and remove specific permissions
# - "99-" prefix ensures this file loads last (lexicographical order), giving it precedence
sudo tee /etc/sudoers.d/99-deploy <<'EOF'
# Allow deploy user to run deployment commands without password
deploy ALL=(root) NOPASSWD: /bin/mkdir, /usr/bin/mkdir, /bin/cp, /usr/bin/cp, /bin/rm, /usr/bin/rm, /bin/tar, /usr/bin/tar, /bin/find, /usr/bin/find, /bin/chgrp, /usr/bin/chgrp, /bin/chmod, /usr/bin/chmod, /bin/ln, /usr/bin/ln, /bin/systemctl reload nginx, /usr/bin/systemctl reload nginx, /bin/ls, /usr/bin/ls, /bin/xargs, /usr/bin/xargs
EOF
sudo chmod 440 /etc/sudoers.d/99-deploy  # Secure permissions (read-only for owner and group)

# ---------- Initial placeholder ----------
# Set up release-based deployment structure for zero-downtime deployments
sudo mkdir -p "$RELEASES_DIR"  # Create directory to store all deployment versions
sudo mkdir -p "$WEBROOT"       # Ensure target directory exists before removing

# Create timestamped release directory for the initial placeholder
INIT_RELEASE="$RELEASES_DIR/$(date +%Y%m%d%H%M%S)_init"  # e.g., /var/www/releases/20241006143022_init
sudo mkdir -p "$INIT_RELEASE"

# Create initial placeholder HTML file in the release directory
sudo tee "$INIT_RELEASE/index.html" <<'HTML'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Vite App</title></head>
  <body style="font-family: system-ui, sans-serif; margin: 40px;">
    <h1>It works 🎉</h1>
    <p>This is the initial placeholder. Your CI/CD will deploy the Vite build here.</p>
  </body>
</html>
HTML

# Atomic deployment: remove existing webroot and create symlink to new release
# This pattern allows zero-downtime deployments by switching symlinks atomically
sudo rm -rf "$CURRENT_LINK"                # Remove existing webroot directory/symlink
sudo ln -sfn "$INIT_RELEASE" "$CURRENT_LINK"  # Create symlink: /var/www/html -> /var/www/releases/20241006143022_init

# Set proper permissions for nginx to serve files
sudo chgrp -R nginx "$RELEASES_DIR"                              # Set group ownership to nginx
# Note: These find commands set different permissions for directories vs files:
# - Directories need execute permission (755) for nginx to traverse them
# - Files only need read permission (644) for nginx to serve them
# - The -exec option runs chmod once for each found item (not a pipe operation)
# - {} is replaced with each file/directory path, \; terminates the -exec command
sudo find "$RELEASES_DIR" -type d -exec chmod 755 {} \;          # Directories: read/write/execute for owner, read/execute for group/others
sudo find "$RELEASES_DIR" -type f -exec chmod 644 {} \;          # Files: read/write for owner, read for group/others
# chmod can be used using regex

# ---------- Nginx SPA config ----------
# Configure nginx for Single Page Application (SPA) hosting with performance optimizations
sudo tee /etc/nginx/conf.d/default.conf <<'NGINX'
server {
    listen 80 default_server;
    server_name _;

    root /var/www/html;  # Points to our symlink for atomic deployments
    index index.html;

    # SPA routing support: serve index.html for any route that doesn't match a file
    # This allows client-side routing (React Router, Vue Router, etc.) to work
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Asset optimization: cache static assets for 7 days
    # Matches CSS, JS, images, fonts, etc.
    location ~* \.(?:css|js|mjs|png|jpg|jpeg|gif|svg|ico|webp|woff2?)$ {
        expires 7d;
        add_header Cache-Control "public, max-age=604800, immutable";
        try_files $uri /index.html;
    }
}
NGINX

# Test nginx configuration and reload if valid
# Note: nginx -t tests configuration syntax without affecting running service
# Note: && ensures reload only happens if config test passes (prevents breaking nginx)
sudo nginx -t && sudo systemctl reload nginx
echo "User data completed successfully (Amazon Linux 2)."
