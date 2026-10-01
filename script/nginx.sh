#!/bin/bash
# Usage: bash setup-core-web.sh <oblada|molly>

NODE=$1
[ "$NODE" != "oblada" ] && [ "$NODE" != "molly" ] && echo "Usage: $0 <oblada|molly>" && exit 1

apt update -qq
apt install -y nginx php-fpm php-cli >/dev/null 2>&1

PHPVER=$(ls /etc/php/ | head -1)
echo "PHP: $PHPVER"

mkdir -p /var/www/core

cat >/var/www/core/index.php <<'EOF'
<?php
$host = gethostname();
$ip   = $_SERVER['SERVER_ADDR'] ?? 'unknown';
?>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Beranda</title></head>
<body>
<h1>Beranda</h1>
<p>Hostname: <?= htmlspecialchars($host) ?></p>
<p>IP: <?= htmlspecialchars($ip) ?></p>
<p>Waktu: <?= date('Y-m-d H:i:s') ?></p>
<ul>
<li><a href="/">Beranda</a></li>
<li><a href="/profil">Profil</a></li>
</ul>
</body>
</html>
EOF

cat >/var/www/core/profil.php <<'EOF'
<?php
$host = gethostname();
$ip   = $_SERVER['SERVER_ADDR'] ?? 'unknown';
?>
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Profil</title></head>
<body>
<h1>Profil</h1>
<p>Nama: Mahasiswa K11</p>
<p>NIM: 12345678</p>
<p>Hostname: <?= htmlspecialchars($host) ?></p>
<p>IP: <?= htmlspecialchars($ip) ?></p>
<p>URI: <?= htmlspecialchars($_SERVER['REQUEST_URI']) ?></p>
<p><a href="/">Kembali</a></p>
</body>
</html>
EOF

cat >/var/www/core/info.php <<'EOF'
<!DOCTYPE html>
<html>
<head><meta charset="UTF-8"><title>Info Core</title></head>
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

chown www-data:www-data /var/www/core/info.php

chown -R www-data:www-data /var/www/core

cat >/etc/nginx/sites-available/core.k11.com <<EOF
server {
    listen 80;
    server_name core.k11.com oblada.k11.com molly.k11.com;
    root /var/www/core;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ =404;
    }

    location = /profil {
        try_files \$uri /profil.php?\$query_string;
    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/run/php/php${PHPVER}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

ln -sf /etc/nginx/sites-available/core.k11.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
service php${PHPVER}-fpm restart
service nginx restart

./setuphost.sh $NODE

echo "Beranda : $(curl -s -o /dev/null -w '%{http_code}' http://localhost/)"
echo "Profil  : $(curl -s -o /dev/null -w '%{http_code}' http://localhost/profil)"
echo "Salah   : $(curl -s -o /dev/null -w '%{http_code}' http://localhost/profilabc)"
