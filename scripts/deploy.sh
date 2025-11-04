#!/bin/bash
set -euo pipefail

# Deployment script for Vite app
# This script is executed on the EC2 instance by GitHub Actions

WEBROOT="/var/www/html"
RELEASES_DIR="/var/www/releases"
BUILD_ARCHIVE="/tmp/vite-build.tar.gz"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RELEASE_DIR="$RELEASES_DIR/${TIMESTAMP}_deploy"

echo "🚀 Starting deployment..."
echo "📦 Release: $RELEASE_DIR"

# Check if build archive exists
# Note: [ ! -f "$BUILD_ARCHIVE" ] tests if file does NOT exist (!= negation, -f = regular file test)
if [ ! -f "$BUILD_ARCHIVE" ]; then
    echo "❌ Build archive not found: $BUILD_ARCHIVE"
    exit 1
fi

# Create releases directory if it doesn't exist
sudo mkdir -p "$RELEASES_DIR"

# Create new release directory
echo "📁 Creating release directory..."
sudo mkdir -p "$RELEASE_DIR"

# Extract build to new release directory
echo "📤 Extracting build..."
cd "$RELEASE_DIR"
# Note: tar -xzf extracts compressed archive (-x=extract, -z=gzip, -f=file)
sudo tar -xzf "$BUILD_ARCHIVE"

# Set proper permissions
echo "🔐 Setting permissions..."
sudo chgrp -R nginx "$RELEASES_DIR"
sudo find "$RELEASES_DIR" -type d -exec chmod 755 {} \;
sudo find "$RELEASES_DIR" -type f -exec chmod 644 {} \;

# Create symlink to new release (atomic deployment)
echo "🔗 Updating symlink..."
sudo ln -sfn "$RELEASE_DIR" "$WEBROOT"

# Reload nginx gracefully
echo "🔄 Reloading nginx..."
sudo systemctl reload nginx

# Clean up old releases (keep last 5)
echo "🧹 Cleaning up old releases..."
cd "$RELEASES_DIR"
# Note: ls -t (sort by time) | tail -n +6 (skip first 5) | xargs rm -rf (delete)
# 2>/dev/null suppresses errors, || true prevents script exit if no files to delete
sudo ls -t | tail -n +6 | sudo xargs rm -rf 2>/dev/null || true

# Verify deployment
# Note: curl -s -f tests if localhost responds (-s=silent, -f=fail on HTTP errors)
# > /dev/null discards output, we only care about exit code
if curl -s -f http://localhost > /dev/null; then
    echo "✅ Deployment successful!"
    echo "🌐 Application is running at: http://$(curl -s http://checkip.amazonaws.com)"
else
    echo "❌ Deployment verification failed!"
    exit 1
fi

# Clean up build archive
rm -f "$BUILD_ARCHIVE"

echo "🎉 Deployment completed successfully!"