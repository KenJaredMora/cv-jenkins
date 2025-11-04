#!/bin/bash
set -eux
#  -e : exit immediately if any command exits with a non-zero status (fail fast)
#  -u : treat unset variables as an error and exit (catch missing vars like SSH_PUBKEY)
#  -x : print each command before executing it (useful for debugging / logs)

sudo yum -y update

sudo amazon-linux-extras install nginx1 -y
sudo systemctl enable --now nginx

WEBROOT="/usr/share/nginx/html"
SSH_PUBKEY="${ssh_pubkey}"

cat > "index.html" <<'HTML'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Vite App</title></head>
  <body style="font-family: system-ui, sans-serif; margin: 40px;">
    <h1>It works 🎉</h1>
    <p>This is the initial placeholder. Your CI/CD will deploy the Vite build here.</p>
  </body>
</html>
HTML

sudo cp "index.html" "$WEBROOT/index.html"