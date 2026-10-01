#!/bin/bash
# Usage: bash setupweb.sh <obladi|desmond>
NODE=$1
apt update && apt install -y apache2
apt install -y libapache2-mod-php

mkdir -p /var/www/html/arsip
if [ "$NODE" = "obladi" ]; then
  echo "Ini arsip rahasia k11.com — file 1" >/var/www/html/arsip/dokumen1.txt
  echo "Ini arsip rahasia k11.com — file 2" >/var/www/html/arsip/dokumen2.txt
  echo "Laporan bulanan" >/var/www/html/arsip/laporan.txt
else
  echo "Ini arsip dari DESMOND — dokumen A" >/var/www/html/arsip/dokumenA.txt
  echo "Ini arsip dari DESMOND — dokumen B" >/var/www/html/arsip/dokumenB.txt
  echo "Laporan dari desmond" >/var/www/html/arsip/laporan-desmond.txt
fi
echo "$NODE" >/var/www/html/arsip/hostname.txt

cat >/etc/apache2/conf-available/arsip.conf <<'EOF'
<Directory /var/www/html/arsip>
    Options Indexes FollowSymLinks
    AllowOverride None
    Require all granted
    IndexOptions FancyIndexing HTMLTable NameWidth=* Charset=UTF-8
</Directory>
EOF

cat >/var/www/html/arsip/info.php <<'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Info Vault</title></head>
<body>
<?php
echo "Host: " . ($_SERVER['HTTP_HOST'] ?? '-') . "<br>";
echo "X-Real-IP: " . ($_SERVER['HTTP_X_REAL_IP'] ?? '-') . "<br>";
echo "X-Forwarded-For: " . ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? '-') . "<br>";
echo "Remote: " . ($_SERVER['REMOTE_ADDR'] ?? '-') . "<br>";
echo "Node: " . gethostname() . "<br>";
?>
</body>
</html>
EOF

chown www-data:www-data /var/www/html/arsip/info.php

echo "ServerName $NODE.k11.com" >/etc/apache2/conf-available/servername.conf

a2enmod php*
a2enconf arsip
a2enconf servername
apache2ctl configtest
service apache2 restart

./setuphost.sh $NODE

echo "== Test lokal =="
curl -s http://localhost/arsip/ | grep -i "index of"
echo "== Test via hostname =="
curl -s http://vault.k11.com/arsip/ | grep -i "index of"
