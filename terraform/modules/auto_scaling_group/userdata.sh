#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y unzip curl jq

DB_SECRET_ARN="${DB_SECRET_ARN}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"

: "$${DB_SECRET_ARN:?DB_SECRET_ARN is required}"
: "$${DB_HOST:?DB_HOST is required}"
: "$${DB_NAME:?DB_NAME is required}"

# Install AWS CLI v2 (latest official package from AWS)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmpDB_SECRET_ARN="${DB_SECRET_ARN}"
DB_HOST="${DB_HOST}"
DB_NAME="${DB_NAME}"
/tmp/aws/install

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "${DB_SECRET_ARN}" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.password')

cd /var/www/html

# wait until WordPress files exist (defensive)
while [ ! -f wp-config-sample.php ]; do
  echo "Waiting for WordPress files..."
  sleep 5
done

# Create wp-config.php if missing
if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
fi

cat <<EOF >> /var/www/html/wp-config.php

define('DB_NAME', '${DB_NAME}');
define('DB_USER', '$${DB_USER}');
define('DB_PASSWORD', '$${DB_PASSWORD}');
define('DB_HOST', '${DB_HOST}');
EOF

grep -q "WP_HOME" wp-config.php || cat <<EOF >> wp-config.php
define('WP_HOME', 'http://' . (\$_SERVER['HTTP_HOST'] ?? 'localhost'));
define('WP_SITEURL', 'http://' . (\$_SERVER['HTTP_HOST'] ?? 'localhost'));
EOF


chown www-data:www-data /var/www/html/wp-config.php
