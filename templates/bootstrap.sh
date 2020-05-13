#!/bin/bash

readonly HOST="{{{host}}}"
readonly DOMAIN="{{{domain}}}"
readonly CADDY_URL="{{{caddy_url}}}"

echo "$(date):per-instance:caddy:install:start"
sudo curl -SsL "$CADDY_URL" -o /tmp/caddy.tar.gz
sudo tar zxf /tmp/caddy.tar.gz
sudo mv /tmp/caddy /usr/bin/caddy
sudo chmod 755 /usr/bin/caddy

sudo groupadd caddy --system
sudo useradd caddy \
  --system \
  --gid caddy \
  --create-home \
  --home-dir /var/lib/caddy \
  --shell /usr/sbin/nologin \
  --comment 'Caddy Web Server'

sudo systemctl daemon-reload
sudo systemctl enable caddy
echo "$(date):per-instance:caddy:install:done"

echo "$(date):per-instance:caddy:dnslookup:start"
while
  ok=0
  dns_ipv4=$(dig @8.8.8.8 +short $HOST.$DOMAIN)
  if [ -n "$dns_ipv4" ]; then
    public_ipv4=$(curl -s 169.254.169.254/latest/meta-data/public-ipv4)
    [ "$dns_ipv4" == "$public_ipv4" ] && ok=1
  fi
  (( $ok == 0 ))
do
  echo "$(date):per-instance:caddy:dnslookup:sleep"
  sleep 5
done
echo "$(date):per-instance:caddy:dnslookup:done"

echo "$(date):per-instance:caddy:run:start"
while [ ! -f "$(find /var/lib/caddy/ -name $HOST.$DOMAIN.crt)" ]; do
  sudo systemctl restart caddy
  echo "$(date):per-instance:caddy:run:sleep"
  sleep 60
done
echo "$(date):per-instance:caddy:run:done"
