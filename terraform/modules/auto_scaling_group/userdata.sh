#!/bin/bash
set -euxo pipefail

# Install dependencies
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y unzip curl jq php-mysql
elif command -v yum >/dev/null 2>&1; then
  yum install -y unzip curl jq php-mysqlnd
else
  echo "Unsupported OS"
  exit 1
fi

# Terraform-injected variables
DB_SECRET_ARN="${DB_SECRET_ARN}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"

: "$${DB_SECRET_ARN:?DB_SECRET_ARN is required}"
: "$${DB_HOST:?DB_HOST is required}"
: "$${DB_NAME:?DB_NAME is required}"

# Strip port from DB_HOST (WordPress does NOT want it)
DB_HOST_CLEAN="$${DB_HOST%%:*}"

# Install AWS CLI v2 if missing
if ! command -v aws >/dev/null 2>&1; then
  cd /tmp
  curl -s https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
  unzip -q awscliv2.zip
  ./aws/install
fi

# Fetch DB credentials from Secrets Manager
DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${DB_SECRET_ARN}" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.password')

# WordPress directory
WP_DIR="/var/www/html"
cd "$WP_DIR"

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
fi

# Replace DB settings (idempotent — no duplicates ever)
sed -i \
  -e "s/database_name_here/$${DB_NAME}/" \
  -e "s/username_here/$${DB_USER}/" \
  -e "s/password_here/$${DB_PASSWORD}/" \
  -e "s/localhost/$${DB_HOST_CLEAN}/" \
  /var/www/html/wp-config.php

# Ensure correct permissions
chown www-data:www-data wp-config.php
chmod 640 wp-config.php

# Restart Apache to be safe
systemctl restart apache2
