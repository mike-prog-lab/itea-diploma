#!/usr/bin/env bash
sudo apt-get update -y

sudo apt-get install -y curl openssh-server ca-certificates tzdata perl

debconf-set-selections <<< "postfix postfix/mailname string $(curl "http://169.254.169.254/latest/meta-data/local-ipv4")"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install --assume-yes postfix

sudo mkdir -p /etc/gitlab/ssl/
sudo openssl genrsa -out /etc/gitlab/ssl/gitlab.key 2048
sudo openssl req -new -nodes rsa:4096 \
  -key /etc/gitlab/ssl/gitlab.key \
  -out /etc/gitlab/ssl/gitlab.csr \
  -subj "/C=UA/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

sudo openssl x509 -req -days 365 \
  -in /etc/gitlab/ssl/gitlab.csr \
  -signkey /etc/gitlab/ssl/gitlab.key \
  -out /etc/gitlab/ssl/gitlab.crt \
  -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com"

curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.deb.sh | sudo bash

sudo EXTERNAL_URL="http://$(curl "http://169.254.169.254/latest/meta-data/local-ipv4")" apt-get -y install gitlab-ee
