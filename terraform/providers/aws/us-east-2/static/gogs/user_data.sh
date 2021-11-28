#!/usr/bin/env bash
sudo apt-get update -y
sudo apt-get install -y git build-essential libpam0g-dev

wget https://dl.google.com/go/go1.17.3.linux-amd64.tar.gz &&
  tar -C /usr/local -xzf go1.17.3.linux-amd64.tar.gz &&
  mkdir ~/.go ||
  exit 1

sudo update-alternatives --install "/usr/bin/go" "go" "/usr/local/go/bin/go" 0
sudo update-alternatives --set go /usr/local/go/bin/go

sudo adduser --disabled-login --gecos 'Gogs' git
cd /home/git || exit 1

export GOROOT=/usr/local/go
export GOPATH=~/.go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

git clone --depth 1 https://github.com/gogs/gogs.git gogs
sudo chown -R git:git /home/git/gogs
cd /home/git/gogs &&
  runuser -l git -c "cd /home/git/gogs/ && go build -tags \"pam cert\" gogs.go" &&
  runuser -l git -c "cd /home/git/gogs/ && ./gogs cert -ca=true -duration=8760h0m0s -host=$(curl "http://169.254.169.254/latest/meta-data/local-ipv4")"

cat <<EOF | sudo tee -a /etc/systemd/system/gogs.service
[Unit]
Description=Gogs
After=syslog.target
After=network.target
After=mariadb.service mysqld.service postgresql.service memcached.service redis.service

[Service]
# Modify these two values and uncomment them if you have
# repos with lots of files and get an HTTP error 500 because
# of that
###
#LimitMEMLOCK=infinity
#LimitNOFILE=65535
Type=simple
User=git
Group=git
WorkingDirectory=/home/git/gogs
ExecStart=/home/git/gogs/gogs web
Restart=always
Environment=USER=git HOME=/home/git

# Some distributions may not support these hardening directives. If you cannot start the service due
# to an unknown option, comment out the ones not supported by your version of systemd.
ProtectSystem=full
PrivateDevices=yes
PrivateTmp=yes
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable gogs &&
  sudo systemctl start gogs

runuser -l git -c "mkdir -p /home/git/gogs/custom/conf || exit 1"

cat <<EOF | runuser -l git -c "tee /home/git/gogs/custom/conf/app.ini"
BRAND_NAME = ITEA devops diploma
RUN_USER   = git
RUN_MODE   = prod

[repository]
ROOT = /home/git/gogs-repositories

[server]
PROTOCOL = https
DOMAIN           = $(curl "http://169.254.169.254/latest/meta-data/local-ipv4")
HTTP_PORT        = 3000
CERT_FILE        = /home/git/gogs/cert.pem
KEY_FILE         = /home/git/gogs/key.pem
EXTERNAL_URL     = https://$(curl "http://169.254.169.254/latest/meta-data/local-ipv4"):3000/
DISABLE_SSH      = false
SSH_PORT         = 22
START_SSH_SERVER = false
OFFLINE_MODE     = false

[mailer]
ENABLED = false

[auth]
REQUIRE_EMAIL_CONFIRMATION  = false
DISABLE_REGISTRATION        = false
ENABLE_REGISTRATION_CAPTCHA = true
REQUIRE_SIGNIN_VIEW         = false

[user]
ENABLE_EMAIL_NOTIFICATION = false

[picture]
DISABLE_GRAVATAR        = false
ENABLE_FEDERATED_AVATAR = false

[session]
PROVIDER = file

[log]
MODE      = file
LEVEL     = Info
ROOT_PATH = /home/git/gogs/log
EOF

sudo systemctl restart gogs