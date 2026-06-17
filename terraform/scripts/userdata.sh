#!/bin/bash
set -euxo pipefail

# Install dependencies
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y unzip curl jq php-mysql amazon-efs-utils  
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
EFS_ID="${EFS_ID}"

if [ -z "$${DB_SECRET_ARN}" ] || [ -z "$${DB_HOST}" ] || [ -z "$${DB_NAME}" ] || [ -z "$${EFS_ID}" ]; then
  echo "Missing required variables"
  exit 1
fi

# Strip port from DB_HOST 
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
  --secret-id "$${DB_SECRET_ARN}" \
  --query SecretString \
  --output text) 

DB_USER=$(echo "$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.password')

# WordPress directory
WP_DIR="/var/www/html"
WP_CONFIG="/var/www/html/wp-config.php"
cd "$WP_DIR"

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  cp -f wp-config-sample.php wp-config.php
fi

cat > wp-config.php <<EOF
<?php

define('DB_NAME', '$${DB_NAME}');
define('DB_USER', '$${DB_USER}');
define('DB_PASSWORD', '$${DB_PASSWORD}');
define('DB_HOST', '$${DB_HOST_CLEAN}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

\$table_prefix = 'wp_';

define('WP_HOME', 'https://wordpress.mike71techsolutions.com');
define('WP_SITEURL', 'https://wordpress.mike71techsolutions.com');

/* HTTPS handling behind ALB */
if (
    isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) &&
    \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https'
) {
    \$_SERVER['HTTPS'] = 'on';
}

/* Absolute path */
if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

/* WordPress core loader */
require_once ABSPATH . 'wp-settings.php';

EOF

# Mount EFS
mkdir -p /mnt/efs
mount -t efs -o tls "${EFS_ID}:/" /mnt/efs || {
  echo "EFS mount failed"
  exit 1
}

echo "${EFS_ID}:/ /mnt/efs efs tls,_netdev 0 0" >> /etc/fstab

# Ensure correct permissions
chown -R www-data:www-data /var/www/html
chmod 644 wp-config.php

# Restart Apache to be safe
systemctl restart apache2
