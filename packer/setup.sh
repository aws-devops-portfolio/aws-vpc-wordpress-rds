#!/bin/bash
set -e

exec > >(tee /var/log/packer.log) 2>&1

apt-get update -y
apt-get install -y apache2 php php-mysqlnd wget unzip curl jq

systemctl enable apache2
systemctl start apache2

cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

# Clean Apache default
rm -rf /var/www/html/*

# Copy WordPress into web root
cp -r /tmp/wordpress/* /var/www/html/

# Permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html