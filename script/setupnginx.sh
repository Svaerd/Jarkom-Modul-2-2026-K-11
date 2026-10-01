#!/bin/bash

apt update
apt install -y nginx

cat >/etc/nginx/sites-available/default <<'EOF'
    upstream corecluster {
        server 10.69.3.14;
        server 10.69.3.15;
    }
    
    server {
    listen 80;

    location / {
        # 1. Meneruskan identitas asli pengunjung
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        # 2. Mengarahkan lalu lintas ke grup upstream
        proxy_pass http://corecluster;
    }
}
EOF

service nginx restart
