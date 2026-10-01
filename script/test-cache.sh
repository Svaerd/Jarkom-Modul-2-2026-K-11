#!/bin/bash

echo "[1] Cek IP sekarang (Efek Cache):"
dig abbey.k11.com +short

echo "[2] Menunggu 16 detik (Batas TTL)..."
sleep 16

echo "[3] Cek IP setelah TTL habis:"
dig abbey.k11.com +short

echo "[4] Cek sinkronisasi di Tedd (Slave DNS):"
dig @10.69.3.11 abbey.k11.com +short
