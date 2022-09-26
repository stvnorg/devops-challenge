#!/bin/bash

apt update
apt install -y nginx
echo "<!DOCTYPE html><head><title>DevOps Challenge</title></head><body><h1 style='text-align:center;font-family:sans-serif'>${candidate}</h1></body>" > /tmp/index.html
cp /tmp/index.html /var/www/html/
systemctl start nginx
systemctl enable nginx

