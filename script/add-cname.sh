#!/bin/bash

# menambahkan cname
echo "outbound  IN  CNAME  http.badssl.com." >>/etc/bind/db.k11.com

# Naikkan serial SOA agar tedd update datanya
sed -i 's/2025010104/2025010105/' /etc/bind/db.k11.com

# reload
service named reload
