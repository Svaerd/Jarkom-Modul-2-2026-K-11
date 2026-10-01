#!/bin/bash

cat >>/etc/bind/db.k11.com <<'EOF'
;soal 17
alpha   IN  TXT "alpha"
beta    IN  TXT "beta"
gamma   IN  TXT "gamma"
delta   IN  TXT "delta"
epsilon IN  TXT "epsilon"
EOF

service named restart
