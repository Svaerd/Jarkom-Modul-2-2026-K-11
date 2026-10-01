#!/bin/bash
# Fix Apache log IP asli (obladi & desmond)

a2enmod remoteip

cat >/etc/apache2/conf-available/remoteip.conf <<'EOF'
RemoteIPHeader X-Real-IP
RemoteIPInternalProxy 10.69.4.10
RemoteIPInternalProxy 10.69.2.10
EOF

a2enconf remoteip

# Ganti LogFormat: %a → %{X-Real-IP}i
sed -i 's|LogFormat "%a %l %u %t|LogFormat "%{X-Real-IP}i %l %u %t|' /etc/apache2/apache2.conf

apache2ctl configtest
service apache2 restart
