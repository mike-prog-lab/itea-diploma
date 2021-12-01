#!/usr/bin/env bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  "https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list >/dev/null

sudo apt-get -y update
sudo apt-get -y install nginx openjdk-11-jdk jenkins

sudo rm /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
sudo mkdir /var/log/nginx/jenkins

mkdir /etc/nginx/ssl && cd /etc/nginx/ssl && sudo openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout key.pem \
  -out cert.pem \
  -sha256 -days 365 \
  -subj "/C=UA/ST=Denial/L=Springfield/O=Dis/CN=$(curl "http://169.254.169.254/latest/meta-data/local-ipv4")"

cat <<EOF | sudo tee "/etc/nginx/conf.d/jenkins.conf"
upstream jenkins {
  keepalive 32; # keepalive connections
  server 127.0.0.1:8080; # jenkins ip and port
}

# Required for Jenkins websocket agents
map \$http_upgrade \$connection_upgrade {
  default upgrade;
  '' close;
}

server {
  listen [::]:443 ssl ipv6only=on;
  listen 443 ssl default_server;
  access_log            /var/log/nginx/jenkins.access.log;
  error_log             /var/log/nginx/jenkins.error.log;

  ssl_certificate     /etc/nginx/ssl/jenkins/cert.pem;
  ssl_certificate_key /etc/nginx/ssl/jenkins/key.pem;
  ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;

  # pass through headers from Jenkins that Nginx considers invalid
  ignore_invalid_headers off;

  location ~ "^/static/[0-9a-fA-F]{8}\/(.*)\$" {
    rewrite "^/static/[0-9a-fA-F]{8}\/(.*)" /\$1 last;
  }

  location /userContent {
    root /var/lib/jenkins/;
    if (!-f \$request_filename){
      rewrite (.*) /\$1 last;
      break;
    }
    sendfile on;
  }

  location / {
      sendfile           off;
      proxy_pass         http://jenkins;
      proxy_redirect     default;
      proxy_http_version 1.1;

      # Required for Jenkins websocket agents
      proxy_set_header   Connection        \$connection_upgrade;
      proxy_set_header   Upgrade           \$http_upgrade;

      proxy_set_header   Host              \$host:\$server_port;
      proxy_set_header   X-Real-IP         \$remote_addr;
      proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
      proxy_set_header   X-Forwarded-Host  \$host;
      proxy_set_header   X-Forwarded-Port  \$server_port;
      proxy_set_header   X-Forwarded-Proto \$scheme;

      proxy_max_temp_file_size 0;

      #this is the maximum upload size
      client_max_body_size       10m;
      client_body_buffer_size    128k;

      proxy_connect_timeout      90;
      proxy_send_timeout         90;
      proxy_read_timeout         90;
      proxy_buffering            off;
      proxy_request_buffering    off; # Required for HTTP CLI commands
      proxy_set_header Connection ""; # Clear for keepalive
  }
}

server {
  listen 80 default_server;

  return 301 https://\$host\$request_uri;
}
EOF

sudo usermod -aG jenkins www-data

JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT --httpListenAddress=127.0.0.1"