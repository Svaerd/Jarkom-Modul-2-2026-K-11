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
echo "$NODE" >/etc/hostname
hostname "$NODE"

# Set /etc/hosts
cat >/etc/hosts <<EOF
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
  echo "nameserver 10.69.3.11" >/etc/resolv.conf
  echo "nameserver 192.168.122.1" >>/etc/resolv.conf
elif [ "$NODE" = "tedd" ]; then
  echo "nameserver 10.69.3.10" >/etc/resolv.conf
  echo "nameserver 192.168.122.1" >>/etc/resolv.conf
else
  echo "nameserver 10.69.3.10" >/etc/resolv.conf
  echo "nameserver 10.69.3.11" >>/etc/resolv.conf
  echo "nameserver 192.168.122.1" >>/etc/resolv.conf
fi

echo "[OK] Hostname: $(hostname)"
echo "[OK] FQDN: $(hostname -f)"
echo "[OK] Resolver:"
cat /etc/resolv.conf
