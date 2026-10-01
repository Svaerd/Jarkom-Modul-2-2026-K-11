#!/bin/bash
# setuporion.sh — Soal 15: /orion di Abbey (statis murni)

mkdir -p /var/www/orion
echo "<h1>Orion OK</h1><p>Halo dari /orion</p>" >/var/www/orion/index.html
echo "File statis orion" >/var/www/orion/data.txt
chown -R www-data:www-data /var/www/orion

CONF=/etc/nginx/sites-available/core-proxy.conf

# Tambah location /orion/ ke server block static.k11.com (sebelum location /)
grep -q "location /orion/" "$CONF" || {
  # Cari server block static.k11.com, sisipkan location /orion/ sebelum location /
  sed -i '0,/location \/ {/s//location \/orion\/ {\n        alias \/var\/www\/orion\/;\n        autoindex on;\n        index index.html;\n    }\n\n    location \/ {/' "$CONF"
}

nginx -t
service nginx reload
