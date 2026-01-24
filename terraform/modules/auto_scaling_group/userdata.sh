#!/bin/bash
set -e

DB_SECRET_ARN="${DB_SECRET_ARN}"
DB_HOST="${TF_DB_ENDPOINT}"
DB_NAME="${TF_DB_NAME}"

DB_SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --query SecretString \
  --output text)

DB_USER=$(echo "$DB_SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$DB_SECRET_JSON" | jq -r '.password')

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i "s|define( 'DB_NAME'.*|define( 'DB_NAME', '$DB_NAME' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_USER'.*|define( 'DB_USER', '$DB_USER' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_PASSWORD'.*|define( 'DB_PASSWORD', '$DB_PASSWORD' );|" /var/www/html/wp-config.php
sed -i "s|define( 'DB_HOST'.*|define( 'DB_HOST', '$DB_HOST' );|" /var/www/html/wp-config.php

chown www-data:www-data /var/www/html/wp-config.php