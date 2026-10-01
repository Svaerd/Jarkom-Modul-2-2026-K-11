#!/bin/bash
# setupadmin.sh — Basic auth /admin di Penny

apt update
apt install -y apache2 apache2-utils

a2enmod proxy proxy_http proxy_balancer lbmethod_byrequests headers auth_basic authn_file

# Direktori admin
mkdir -p /var/www/admin
echo "Dokumen rahasia admin K11" >/var/www/admin/rahasia.txt
echo "Selamat datang, admin dunia" >/var/www/admin/index.html

# Password file
htpasswd -cb /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'

# Config PALING AKHIR
cat >/etc/apache2/sites-available/000-default.conf <<'EOF'
<VirtualHost *:80>
    ServerName www.k11.com
    ServerName penny.k11.com

    Alias /admin /var/www/admin

    <Directory /var/www/admin>
        AuthType Basic
        AuthName "Ruang Rahasia Admin dunia"
        AuthUserFile /etc/apache2/.htpasswd
        Require valid-user
    </Directory>

    <Proxy balancer://vaultcluster>
        BalancerMember http://10.69.3.12:80
        BalancerMember http://10.69.3.13:80
        ProxySet lbmethod=byrequests

        RequestHeader set X-Real-IP "expr=%{REMOTE_ADDR}"
        RequestHeader set X-Forwarded-For "expr=%{REMOTE_ADDR}"
    </Proxy>

    ProxyPreserveHost On
    ProxyPass        /admin !
    ProxyPass        /  balancer://vaultcluster/
    ProxyPassReverse /  balancer://vaultcluster/
    ProxyPassReverse /  http://10.69.3.12/
    ProxyPassReverse /  http://10.69.3.13/
</VirtualHost>
EOF

echo "ServerName penny.k11.com" >/etc/apache2/conf-available/servername.conf
a2enconf servername

apache2ctl configtest
service apache2 restart
