#!/bin/bash
wget https://ko.wordpress.org/wordpress-7.0.2-ko_KR.tar.gz
dnf install -y httpd php php-curl php-gd php-mysqlnd
tar xvfz wordpress-7.0.2-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html/
cp -ar /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
echo $HOSTNAME > /var/www/html/index.html
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php/g' /etc/httpd/conf/httpd.conf
sed -i 's/database_name_here/${db_name}/g' /var/www/html/wp-config.php
sed -i 's/username_here/${db_username}/g' /var/www/html/wp-config.php
sed -i 's/password_here/${db_password}/g' /var/www/html/wp-config.php
sed -i 's/localhost/${db_endpoint}/g' /var/www/html/wp-config.php
chown -R apache:apache /var/www/html/*
systemctl enable --now httpd
