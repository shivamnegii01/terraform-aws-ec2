#!/bin/bush

apt-get update
apt-get install nginx -y
systemctl start nginx
systemctl enable nginx

echo "<h1> Installed Nginx <h1>" | sudo tee /var/www/html/index.html
