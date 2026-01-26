#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y unzip curl

cd /tmp
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip awscliv2.zip
./aws/install

DB_SECRET_ARN="${DB_SECRET_ARN}"
DB_HOST="${TF_DB_ENDPOINT}"
DB_NAME="${TF_DB_NAME}"

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
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

if [ ! -f wp-config.php ]; then
  cp wp-config-sample.php wp-config.php
fi

sed -i "s|define( 'DB_NAME'.*|define( 'DB_NAME', '$DB_NAME' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_USER'.*|define( 'DB_USER', '$DB_USER' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_PASSWORD'.*|define( 'DB_PASSWORD', '$DB_PASSWORD' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_HOST'.*|define( 'DB_HOST', '$DB_HOST' );|" /var/www/html/wp-config.php

sed -i "s|define('WP_HOME'.*|define('WP_HOME', 'http://' . (\$_SERVER['HTTP_HOST'] ?? 'localhost'));|" /var/www/html/wp-config.php
sed -i "s|define('WP_SITEURL'.*|define('WP_SITEURL', 'http://' . (\$_SERVER['HTTP_HOST'] ?? 'localhost'));|" /var/www/html/wp-config.php

chown www-data:www-data /var/www/html/wp-config.php
