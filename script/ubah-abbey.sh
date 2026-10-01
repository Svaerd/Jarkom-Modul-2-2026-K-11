#!/bin/bash

echo "[*] Mengubah Serial SOA dan A Record Abbey..."

# 1. Menaikkan nilai Serial SOA (dari 2025010103 menjadi 2025010104)
sed -i 's/2025010103/2025010104/' /etc/bind/db.k11.com

# 2. Mengubah record abbey menjadi IP fiktif dengan TTL 15 detik
# Regex ^abbey.* akan mencari baris yang diawali kata "abbey" dan menimpanya
sed -i 's/^abbey.*/abbey   15      IN      A       10.88.88.88/' /etc/bind/db.k11.com

# 3. Verifikasi sintaks zona
named-checkzone k11.com /etc/bind/db.k11.com || {
  echo "[FAIL] Zona error!"
  exit 1
}

# 4. Terapkan perubahan tanpa mematikan layanan (reload)
service named reload
