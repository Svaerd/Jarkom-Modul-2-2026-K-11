#!/bin/bash

apt update
apt install -y apache2-utils

ab -n 250 -c 10 http://www.k11.com/
ab -n 250 -c 10 http://static.k11.com/
