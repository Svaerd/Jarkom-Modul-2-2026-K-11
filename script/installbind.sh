#!/bin/bash
# /root/install-bind.sh
# Usage:
#   bash install-bind.sh prab    → master
#   bash install-bind.sh tedd    → slave

ROLE=$1

if [ "$ROLE" != "prab" ] && [ "$ROLE" != "tedd" ]; then
  echo "Usage: $0 <prab|tedd>"
  exit 1
fi

# 1. Update & install
apt update
apt install -y bind9 bind9utils dnsutils

# 2. Common options
cat >/etc/bind/named.conf.options <<EOF
options {
    directory "/var/cache/bind";
    forwarders { 192.168.122.1; };
    recursion yes;
    allow-recursion { 10.69.0.0/16; 127.0.0.1; };
    dnssec-validation no;
    listen-on { any; };
    listen-on-v6 { none; };
};
EOF

# 3. Role-specific zone config
if [ "$ROLE" = "prab" ]; then
  # Master
  cat >/etc/bind/named.conf.local <<EOF
zone "k11.com" {
    type master;
    file "/etc/bind/db.k11.com";
    notify yes;
    also-notify { 10.69.3.11; };
    allow-transfer { 10.69.3.11; };
};
EOF

  # Reverse zones
  cat >>/etc/bind/named.conf.local <<'EOF'

zone "2.69.10.in-addr.arpa" { type master; file "/etc/bind/db.10.69.2"; notify yes; also-notify { 10.69.3.11; }; allow-transfer { 10.69.3.11; }; };
zone "3.69.10.in-addr.arpa" { type master; file "/etc/bind/db.10.69.3"; notify yes; also-notify { 10.69.3.11; }; allow-transfer { 10.69.3.11; }; };
zone "4.69.10.in-addr.arpa" { type master; file "/etc/bind/db.10.69.4"; notify yes; also-notify { 10.69.3.11; }; allow-transfer { 10.69.3.11; }; };
EOF

  cat >/etc/bind/db.10.69.2 <<'EOF'
$TTL 604800
@ IN SOA prab.k11.com. admin.k11.com. ( 2025010103 3600 1800 604800 86400 )
@ IN NS prab.k11.com.
@ IN NS tedd.k11.com.
10 IN PTR abbey.k11.com.
EOF

  cat >/etc/bind/db.10.69.3 <<'EOF'
$TTL 604800
@ IN SOA prab.k11.com. admin.k11.com. ( 2025010103 3600 1800 604800 86400 )
@ IN NS prab.k11.com.
@ IN NS tedd.k11.com.
12 IN PTR vault.k11.com.
13 IN PTR vault.k11.com.
14 IN PTR core.k11.com.
15 IN PTR core.k11.com.
EOF

  cat >/etc/bind/db.10.69.4 <<'EOF'
$TTL 604800
@ IN SOA prab.k11.com. admin.k11.com. ( 2025010103 3600 1800 604800 86400 )
@ IN NS prab.k11.com.
@ IN NS tedd.k11.com.
10 IN PTR penny.k11.com.
EOF

  # Zone file LENGKAP (Soal 4, 5, 7)
  cat >/etc/bind/db.k11.com <<'EOF'
$TTL    604800
@       IN      SOA     prab.k11.com. admin.k11.com. (
                              2025010102 ; Serial
                              3600       ; Refresh
                              1800       ; Retry
                              604800     ; Expire
                              86400 )    ; Negative Cache TTL
;
; NS Records
@       IN      NS      prab.k11.com.
@       IN      NS      tedd.k11.com.
;
; Apex (dynamic app gateway)
@       IN      A       10.69.4.10
;
; DNS Server
prab    IN      A       10.69.3.10
tedd    IN      A       10.69.3.11
;
; Node lain
alpha   IN      A       10.69.1.10
beta    IN      A       10.69.1.11
gamma   IN      A       10.69.1.12
abbey   IN      A       10.69.2.10
penny   IN      A       10.69.4.10
delta   IN      A       10.69.5.10
epsilon IN      A       10.69.5.11
obladi  IN      A       10.69.3.12
desmond IN      A       10.69.3.13
oblada  IN      A       10.69.3.14
molly   IN      A       10.69.3.15
rootkit IN      A       10.69.3.1
; soal 7
; vault -> obladi + desmond (load balance)
vault   IN      A       10.69.3.12
vault   IN      A       10.69.3.13
;
; core -> oblada + molly (load balance)
core    IN      A       10.69.3.14
core    IN      A       10.69.3.15
;
; CNAME alias
www     IN      CNAME   penny.k11.com.
static  IN      CNAME   abbey.k11.com.
EOF

elif [ "$ROLE" = "tedd" ]; then
  # Slave
  cat >/etc/bind/named.conf.local <<EOF
zone "k11.com" {
    type slave;
    file "/var/cache/bind/db.k11.com";
    masters { 10.69.3.10; };
};
EOF

  cat >>/etc/bind/named.conf.local <<'EOF'

zone "2.69.10.in-addr.arpa" { type slave; file "/var/cache/bind/db.10.69.2"; masters { 10.69.3.10; }; };
zone "3.69.10.in-addr.arpa" { type slave; file "/var/cache/bind/db.10.69.3"; masters { 10.69.3.10; }; };
zone "4.69.10.in-addr.arpa" { type slave; file "/var/cache/bind/db.10.69.4"; masters { 10.69.3.10; }; };
EOF
fi

# 4. Cek syntax
echo "[*] Cek syntax..."
named-checkconf || {
  echo "[FAIL] named-checkconf"
  exit 1
}

if [ "$ROLE" = "prab" ]; then
  named-checkzone k11.com /etc/bind/db.k11.com || {
    echo "[FAIL] named-checkzone"
    exit 1
  }
fi

# 5. Restart service
echo "[*] Restart named..."
service named restart
sleep 2
service named status

# 6. Cek listen
echo "[*] Listen port 53:"
ss -tlnp | grep :53 || netstat -tlnp | grep :53

# 7. Test lokal
echo "[*] Test query k11.com..."
dig -4 @localhost k11.com +short
echo "[*] Test vault.k11.com..."
dig -4 @localhost vault.k11.com +short
echo "[*] Test www.k11.com..."
dig -4 @localhost www.k11.com +short

echo "[DONE] $ROLE siap."
