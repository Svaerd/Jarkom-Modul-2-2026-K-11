#!/bin/bash
# reverseproxy.sh — Penny (Apache → vault)
# Usage: bash reverseproxy.sh

apt update
apt install -y apache2 apache2-utils

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers

# ===== Config file PALING AKHIR =====
cat >/etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerName www.k11.com
    ServerName penny.k11.com

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.69.3.12:80
        BalancerMember http://10.69.3.13:80
        ProxySet lbmethod=byrequests

        RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"
        RequestHeader set X-Forwarded-For "expr=%{REMOTE_ADDR}"
    </Proxy>

    ProxyPreserveHost On
    ProxyPass        /  balancer://vaultcluster/
    ProxyPassReverse /  balancer://vaultcluster/
    ProxyPassReverse /  http://10.69.3.12/
    ProxyPassReverse /  http://10.69.3.13/
</VirtualHost>
EOF

echo "ServerName penny.k11.com" >/etc/apache2/conf-available/servername.conf
a2enconf servername

apache2ctl configtest
(sleep 5 && service apache2 restart) &

bash /root/setuphost.sh penny
