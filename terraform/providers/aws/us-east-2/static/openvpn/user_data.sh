#!/usr/bin/env bash
sudo apt -y update
sudo apt -y upgrade

sudo apt update && sudo apt -y install ca-certificates wget net-tools gnupg awscli jq
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main" >/etc/apt/sources.list.d/openvpn-as-repo.list
sudo apt update && sudo apt -y install openvpn-as

OPENVPN_PASSWORD="$(aws ssm get-parameter --name /openvpn/initial/password --with-decryption --region us-east-2 | jq -cr .Parameter.Value)"

sudo useradd openvpn

sudo echo "openvpn:$OPENVPN_PASSWORD" | sudo chpasswd
