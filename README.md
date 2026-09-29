# Jarkom-Modul-2-2026-K-11

## Anggota Kelompok
| Nama                | NRP        | Pembagian Soal   | Pembagian Jobdesk                                                      |
| ------------------- | ---------- | ---------------- | ---------------------------------------------------------------------- |
| Hasheemi Rafsanjani | 5027251015 | 7-14, 16, 18, 20 | Main Solver (menyelesaikan sebagian besar tantangan/soal)              |
| Husam Danish        | 5027251060 | 1-6, 15, 17, 19  | Main Editor (Resolve git conflict dan melakukan editing serta koreksi) |

## Laporan Shadow Net Operation

### Glosarium Entitas
```
rootkit : router sentral (gateway)
alpha, beta, gamma : klien sayap kiri (pengamat)
delta, epsilon : klien sayap kanan (eksekutor)
abbey, penny : gerbang penyaring (reverse proxy)
prab : penjaga nama utama (ns1)
tedd : penjaga nama bayangan (ns2)
obladi, desmond : repositori web statis
oblada, molly : repositori web dinamis
<xxxx> : Isi dengan nama kelompok, contoh: K01
Aturan resolver awal : setiap tokoh (host) non-router menambahkan nameserver 192.168.122.1 saat UI aktif (untuk memudahkan akses & instalasi paket yang dibutuhkan di awal).
Penataan ulang resolver : setelah DNS internal hidup (soal 5), urutkan menjadi prab → tedd → 192.168.122.1 pada semua non-router.
Area vault : Kelompok repository web statis yang terdiri dari node obladi dan desmond.
Area core: Kelompok repository web dinamis yang terdiri dari node oblada dan molly. 
Kanonik : Hostname utama yang menjadi identitas publik layanan. Semua akses lewat IP atau nama lain akan dialihkan secara permanen ke hostname ini (misal: www.<xxxx>.com).
Disarankan menggunakan >= php8.4-fpm.
```
### 1. The Mesh - set up topology
![](./Attachments/image-1.webp)

### 2.  Set IP VPC

Router config:
```
auto eth0
iface eth0 inet dhcp

up sysctl -w net.ipv4.ip_forward=1
up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
up iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth3 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth4 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth5 -o eth0 -j ACCEPT
up iptables -A FORWARD -i eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT

auto eth1
iface eth1 inet static
address 10.69.1.1
netmask 255.255.255.0

auto eth2
iface eth2 inet static
address 10.69.2.1
netmask 255.255.255.0

auto eth3
iface eth3 inet static
address 10.69.3.1
netmask 255.255.255.0

auto eth4
iface eth4 inet static
address 10.69.4.1
netmask 255.255.255.0

auto eth5
iface eth5 inet static
address 10.69.5.1
netmask 255.255.255.0
```

> Config masing-masing clients: assigning Clients IP
- delta
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.5.10
netmask 255.255.255.0
gateway 10.69.5.1
```
- epsilon
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.5.11
netmask 255.255.255.0
gateway 10.69.5.1
```

- penny
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.4.10
netmask 255.255.255.0
gateway 10.69.4.1
```

- molly
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.15
netmask 255.255.255.0
gateway 10.69.3.1
```
- oblada
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.14
netmask 255.255.255.0
gateway 10.69.3.1
```
- desmond
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.13
netmask 255.255.255.0
gateway 10.69.3.1
```
- obladi
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.12
netmask 255.255.255.0
gateway 10.69.3.1
```
- redd
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.11
netmask 255.255.255.0
gateway 10.69.3.1
```
- prab
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.3.10
netmask 255.255.255.0
gateway 10.69.3.1
```

- abbey
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.2.10
netmask 255.255.255.0
gateway 10.69.2.1
```

- gamma
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.1.12
netmask 255.255.255.0
gateway 10.69.1.1
```
- beta
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.1.11
netmask 255.255.255.0
gateway 10.69.1.1
```
- alpha
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.1.10
netmask 255.255.255.0
gateway 10.69.1.1
```

![](./Attachments/screen-toolkit-annotate-2.webp)

### 3. Set Resolver
>Dari config masing-masing client sebelumnya, selanjutnya kita tambahkan config dns, agar client bisa mengakses domain.
```
#.....config yang sebelumnya
dns-nameservers 192.168.122.1
up echo "nameserver 192.168.122.1" >> /etc/resolv.conf
```

![](./Attachments/screen-toolkit-annotate-3.webp)

### 4. Authoritative DNS config

```sh
#!/bin/bash
# prab (ns1) = master
# bash dns-zone.sh

TEDD_IP=10.69.3.11

apt update
apt install -y bind9 bind9-utils dnsutils

cat > /etc/bind/named.conf.options <<'EOF'
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

cat > /etc/bind/named.conf.local <<EOF
zone "k11.com" {
    type master;
    file "/etc/bind/db.k11.com";
    notify yes;
    also-notify { $TEDD_IP; };
    allow-transfer { $TEDD_IP; };
};
EOF

cat > /etc/bind/db.k11.com <<'EOF'
$TTL    604800
@       IN      SOA     prab.k11.com. admin.k11.com. (
                              2025010101 ; Serial
                              3600 1800 604800 86400 )
;
@       IN      NS      prab.k11.com.
@       IN      NS      tedd.k11.com.
;
@       IN      A       10.69.4.10
prab    IN      A       10.69.3.10
tedd    IN      A       10.69.3.11
penny   IN      A       10.69.4.10
EOF

named-checkconf
named-checkzone k11.com /etc/bind/db.k11.com

service named restart
sleep 3

echo "=== Cek listen ==="
ss -tlnp | grep :53
echo "=== Cek serial ==="
dig -4 @localhost k11.com SOA +short
```

Verifikasi dari client (alpha), setelah resolver di set di `/etc/network/interfaces` sesuai section 3:
```
dig @10.69.3.10 k11.com +short     # harus 10.69.4.10
dig @10.69.3.11 prab.k11.com +short # harus 10.69.3.10
```

<img width="646" height="241" alt="image" src="https://github.com/user-attachments/assets/eb115a3f-6170-4b3f-b1c2-f94d9b1d92ec" />

Selanjutnya tambahkan config terkait dns pada masing-masing node:
```
up echo "nameserver 10.69.3.10" > /etc/resolv.conf
up echo "nameserver 10.69.3.11" >> /etc/resolv.conf
```

contoh config pada alpha:
```
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
address 10.69.1.10
netmask 255.255.255.0
gateway 10.69.1.1
dns-nameservers 10.69.3.10 10.69.3.11 192.168.122.1
up echo "nameserver 10.69.3.10" > /etc/resolv.conf
up echo "nameserver 10.69.3.11" >> /etc/resolv.conf
up echo "nameserver 192.168.122.1" >> /etc/resolv.conf
```

### 5. Domain dan Hostname

`installbind.sh`

Untuk menambahkan subdomain dan mengkoneksikannya dengan IP address sesuai node dan glosarium makan script `dns-zone.sh` di prab akan menambahkan beberapa A record pada `/db.k11.com` sehingga menjadi

```sh
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
cat > /etc/bind/named.conf.options <<EOF
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
    cat > /etc/bind/named.conf.local <<EOF
zone "k11.com" {
    type master;
    file "/etc/bind/db.k11.com";
    notify yes;
    also-notify { 10.69.3.11; };
    allow-transfer { 10.69.3.11; };
};
EOF

    cat > /etc/bind/db.k11.com <<'EOF'
$TTL    604800
@       IN      SOA     prab.k11.com. admin.k11.com. (
                              2025010101 ; Serial
                              3600       ; Refresh
                              1800       ; Retry
                              604800     ; Expire
                              86400 )    ; Negative Cache TTL
;
@       IN      NS      prab.k11.com.
@       IN      NS      tedd.k11.com.
;
@       IN      A       10.69.4.10      ; Apex -> Penny
prab    IN      A       10.69.3.10
tedd    IN      A       10.69.3.11
penny   IN      A       10.69.4.10
alpha   IN      A       10.69.1.10
beta    IN      A       10.69.1.11
gamma   IN      A       10.69.1.12
abbey   IN      A       10.69.2.10
delta   IN      A       10.69.5.10
epsilon IN      A       10.69.5.11
obladi  IN      A       10.69.3.12
desmond IN      A       10.69.3.13
oblada  IN      A       10.69.3.14
molly   IN      A       10.69.3.15
rootkit IN      A       10.69.3.1
EOF

elif [ "$ROLE" = "tedd" ]; then
    # Slave
    cat > /etc/bind/named.conf.local <<EOF
zone "k11.com" {
    type slave;
    file "/var/cache/bind/db.k11.com";
    masters { 10.69.3.10; };
};
EOF
fi

# 4. Cek syntax
echo "[*] Cek syntax..."
named-checkconf || { echo "[FAIL] named-checkconf"; exit 1; }

if [ "$ROLE" = "prab" ]; then
    named-checkzone k11.com /etc/bind/db.k11.com || { echo "[FAIL] named-checkzone"; exit 1; }
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

echo "[DONE] $ROLE siap."

````


`setup-hosts.sh`

Melakukan penamaan hostname dan merefer ke subdomain yang telah dibuat, juga mengenali system-wide untuk semua , maka script dijalankan pada setiap node dengan argumen sesuai nama hostname

```sh
#!/bin/bash
# /root/setup-hosts.sh
# Usage: bash setup-hosts.sh <nama_node>
# Contoh: bash setup-hosts.sh prab

NODE=$1

if [ -z "$NODE" ]; then
    echo "Usage: $0 <nama_node>"
    echo "Contoh: $0 prab"
    exit 1
fi

# Set hostname
echo "$NODE" > /etc/hostname
hostname "$NODE"

# Set /etc/hosts
cat > /etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       ${NODE}.k11.com          ${NODE}

10.69.3.10      prab.k11.com            prab
10.69.3.11      tedd.k11.com            tedd
10.69.4.10      k11.com                 penny.k11.com   penny
10.69.1.10      alpha.k11.com           alpha
10.69.1.11      beta.k11.com            beta
10.69.1.12      gamma.k11.com           gamma
10.69.2.10      abbey.k11.com           abbey
10.69.5.10      delta.k11.com           delta
10.69.5.11      epsilon.k11.com         epsilon
10.69.3.12      obladi.k11.com          obladi
10.69.3.13      desmond.k11.com         desmond
10.69.3.14      oblada.k11.com          oblada
10.69.3.15      molly.k11.com           molly
10.69.3.1       rootkit.k11.com         rootkit

::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF

# Set resolver sesuai node
if [ "$NODE" = "prab" ]; then
    echo "nameserver 10.69.3.11" > /etc/resolv.conf
    echo "nameserver 192.168.122.1" >> /etc/resolv.conf
elif [ "$NODE" = "tedd" ]; then
    echo "nameserver 10.69.3.10" > /etc/resolv.conf
    echo "nameserver 192.168.122.1" >> /etc/resolv.conf
else
    echo "nameserver 10.69.3.10" > /etc/resolv.conf
    echo "nameserver 10.69.3.11" >> /etc/resolv.conf
    echo "nameserver 192.168.122.1" >> /etc/resolv.conf
fi

echo "[OK] Hostname: $(hostname)"
echo "[OK] FQDN: $(hostname -f)"
echo "[OK] Resolver:"
cat /etc/resolv.conf
```
<img width="958" height="403" alt="image" src="https://github.com/user-attachments/assets/79f2a92c-e07f-41d6-9eb6-3814f1364da2" />

<img width="997" height="856" alt="image" src="https://github.com/user-attachments/assets/c5ac08b6-c623-4f63-a340-4e1e82996869" />


### 6. Cek Zona Transfer

Untuk memastikan tedd telah menerima salinan zona terbaru dari prabb, jalankan script dibawah ini pada container tedd:
```sh
#!/bin/bash
echo "Membandingkan Serial SOA"
dig -4 @10.69.3.10 k11.com SOA +short
dig -4 @10.69.3.11 k11.com SOA +short

echo ""
echo "Test Zone Transfer"
dig -4 @10.69.3.10 k11.com AXFR +short | head -5

echo ""
echo "Cek authoritative di Tedd"
dig @10.69.3.11 k11.com
```
![](./Attachments/screen-toolkit-annotate-6.webp)
### 7. Penambahan A record
Untuk menambahkan A record untuk vault.k11.com serta core.k11.com, tambahkan beberapa konfigurasi tambahan pada `/etc/bind/db.k11.com`. Untuk melakukan itu, disini kami menambahkan beberapa line tambahan pada script `installbind.sh`
```sh
...
molly   IN      A       10.69.3.15
rootkit IN      A       10.69.3.1

; ============================================
; Soal 7: Vault, Core, WWW, Static
; ============================================
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
...
```

Selain itu, serialnya juga diganti dari awalnya `2025010101` menjadi `2025010102`:
```sh
...
    cat > /etc/bind/db.k11.com <<'EOF'
$TTL    604800
@       IN      SOA     prab.k11.com. admin.k11.com. (
                              2025010102 ; Serial
                              3600       ; Refresh
...
```

Selanjutnya kita akan melakukan verifikasi pada node `alpha` dan `delta`, bahwa semua hostname sudah terresolve dengan benar, menggunakan script di bawah:
`cekhostname.sh`
```sh
#!/bin/bash
PRAB=10.69.3.10
TEDD=10.69.3.11

# Fungsi untuk mengurangi pengulangan perintah dig
cek() {
    echo "$1"
    echo -n "Prab : "; dig -4 @$PRAB $2 +short | tr '\n' ' '; echo
    echo -n "Tedd : "; dig -4 @$TEDD $2 +short | tr '\n' ' '; echo
    echo ""
}

echo "CHECK SOAL 7"
echo ""

echo "Serial SOA"
echo -n "Prab : "; dig -4 @$PRAB k11.com SOA +short | awk '{print $3}'
echo -n "Tedd : "; dig -4 @$TEDD k11.com SOA +short | awk '{print $3}'
echo ""

# Memanggil fungsi untuk record A, CNAME, dan Apex
cek "vault.k11.com" vault.k11.com
cek "core.k11.com" core.k11.com
cek "www.k11.com" www.k11.com
cek "static.k11.com" static.k11.com
cek "Apex k11.com" k11.com

echo "Authoritative"
echo -n "Prab : "; dig -4 @$PRAB k11.com | grep -o "flags: [^;]*"
echo -n "Tedd : "; dig -4 @$TEDD k11.com | grep -o "flags: [^;]*"
echo ""

echo "Resolver lokal"
grep nameserver /etc/resolv.conf
echo ""
```

![](./Attachments/screen-toolkit-annotate-4.webp)
![](./Attachments/screen-toolkit-annotate-5.webp)