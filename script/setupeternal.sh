#!/bin/bash
# setupeternal.sh — Soal 15: /eternal di Penny
apt install -y libapache2-mod-php
a2enmod php*
mkdir -p /var/www/eternal

cat >/var/www/eternal/index.php <<'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Eternal</title></head>
<body>
<?php
echo "Eternal OK<br>";
echo "Host: " . ($_SERVER['HTTP_HOST'] ?? '-') . "<br>";
echo "Node: " . gethostname() . "<br>";
echo "PHP: " . phpversion() . "<br>";
?>
</body>
</html>
EOF

chown www-data:www-data /var/www/eternal/index.php

echo "Halo dari /eternal" >/var/www/eternal/info.txt
chown -R www-data:www-data /var/www/eternal

CONF=/etc/apache2/sites-available/000-default.conf

# Tambah blok Alias /eternal sebelum Alias /admin
grep -q "Alias /eternal" "$CONF" || sed -i '/Alias \/admin/i\
    Alias /eternal /var/www/eternal\
    <Directory /var/www/eternal>\
        Options Indexes FollowSymLinks\
        AllowOverride None\
        Require all granted\
        DirectoryIndex index.php index.html\
    </Directory>\
' "$CONF"

# Tambah ProxyPass /eternal ! sebelum ProxyPass /admin !
grep -q "ProxyPass        /eternal !" "$CONF" || sed -i '/ProxyPass        \/admin !/i\
    ProxyPass        /eternal !' "$CONF"

apache2ctl configtest
service apache2 restart
