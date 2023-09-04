#!/bin/bash
# system upgrade
apt-get update
apt-get upgrade -y

# docker install
apt-get remove -y docker docker-engine docker.io containerd runc
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg --yes
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# start wordpress in container
docker run \
  -e WORDPRESS_DB_HOST="${db_host}" \
  -e WORDPRESS_DB_USER="${db_user}" \
  -e WORDPRESS_DB_PASSWORD="${db_pass}" \
  -e WORDPRESS_DB_NAME="${db_name}" \
  -p 8080:80 --name=wordpress --restart=unless-stopped wordpress:6.1.1