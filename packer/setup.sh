#!/bin/bash
set -e

# exec > >(tee /var/log/packer.log) 2>&1

set -euxo pipefail

echo "===== OS INFO ====="
lsb_release -a || cat /etc/os-release
uname -a

sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -y
sudo apt-get upgrade -y

echo "===== APT SOURCES ====="
cat /etc/apt/sources.list
ls /etc/apt/sources.list.d || true

# Ensure universe repo is enabled
apt-get install -y software-properties-common
add-apt-repository universe
apt-get update -y

# Install Apache + PHP (Jammy defaults)
apt-get install -y \
  software-properties-common \
  apache2 \
  php \
  php-mysql \
  wget \
  unzip \
  curl \
  jq
  
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
