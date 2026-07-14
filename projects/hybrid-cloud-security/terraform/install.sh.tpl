#!/bin/bash
setenforce 0
grubby --update-kernel --args selinux=0

dnf install -y tar wget httpd php php-mysqlnd php-curl php-gd php-opcache php-xml php-mbstring php-zip php-json mysql

# WordPress 설치
wget https://ko.wordpress.org/wordpress-7.0-ko_KR.tar.gz
tar xfvz wordpress-7.0-ko_KR.tar.gz
cp -ar wordpress/* /var/www/html/

# Apache 설정
sed -i "s/DirectoryIndex index.html/DirectoryIndex index.html index.php/g" /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf
mv /etc/httpd/conf.d/{welcome.conf,welcome.conf.bak}

# WordPress DB 연결 설정
cp /var/www/html/{wp-config-sample.php,wp-config.php}
sed -i "s/database_name_here/wordpress/g" /var/www/html/wp-config.php
sed -i "s/username_here/ijo/g" /var/www/html/wp-config.php
sed -i "s/password_here/It12345@/g" /var/www/html/wp-config.php
sed -i "s/localhost/192.168.3.6/g" /var/www/html/wp-config.php

# 권한 설정
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html/wp-content

# WP-CLI 설치
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

# SELinux 컨텍스트
cd /var/www/html
chcon -R -t httpd_sys_content_t /var/www/html 2>/dev/null
chcon -R -t httpd_sys_rw_content_t /var/www/html/wp-content 2>/dev/null

# ── Azure Files (wp-media) 마운트: 업로드 파일 공유 ──
dnf install -y cifs-utils
mkdir -p /var/www/html/wp-content/uploads
mount -t cifs //${storage_acct}.file.core.windows.net/${share_name} /var/www/html/wp-content/uploads -o vers=3.0,username=${storage_acct},password=${storage_key},uid=apache,gid=apache,dir_mode=0775,file_mode=0664,serverino,nosharesock
echo "//${storage_acct}.file.core.windows.net/${share_name} /var/www/html/wp-content/uploads cifs vers=3.0,username=${storage_acct},password=${storage_key},uid=apache,gid=apache,dir_mode=0775,file_mode=0664,serverino,nosharesock,_netdev 0 0" >> /etc/fstab

# ── 온프레미스 DB(VPN 터널) 연결될 때까지 최대 10분 대기 ──
echo "Waiting for on-prem MySQL via VPN..."
for i in $(seq 1 60); do
  if mysqladmin ping -h 192.168.3.6 -u ijo -pIt12345@ --silent 2>/dev/null; then
    echo "MySQL is reachable. Proceeding."
    break
  fi
  echo "[$i/60] MySQL not reachable yet, retrying in 10s..."
  sleep 10
done

# WordPress 설치 및 플러그인
wp core install \
  --url="http://${site_ip}" \
  --title="SHOP" \
  --admin_user="admin" \
  --admin_password="It12345@" \
  --admin_email="admin@test.local" \
  --skip-email \
  --allow-root

wp plugin install woocommerce --activate --allow-root

# ── Redis Object Cache 연동 (Azure Managed Redis · TLS · 10000) ──
wp plugin install redis-cache --activate --allow-root
wp config set WP_REDIS_HOST "${redis_host}" --allow-root
wp config set WP_REDIS_PORT 10000 --raw --allow-root
wp config set WP_REDIS_PASSWORD "${redis_key}" --allow-root
wp config set WP_REDIS_SCHEME tls --allow-root
wp redis enable --allow-root

wp theme install storefront --activate --allow-root
wp option update template storefront --allow-root
wp option update stylesheet storefront --allow-root
wp option update users_can_register 1 --allow-root
wp option update permalink_structure '/%postname%/' --allow-root --path=/var/www/html

# WooCommerce 카테고리 생성
wp term create product_cat "Clothing" --slug=clothing --allow-root
wp term create product_cat "Bags" --slug=bags --allow-root
wp term create product_cat "Shoes" --slug=shoes --allow-root
wp term create product_cat "Accessories" --slug=accessories --allow-root

# .htaccess 생성
cat > /var/www/html/.htaccess << 'HTEOF'
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %%{REQUEST_FILENAME} !-f
RewriteCond %%{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
HTEOF

wp rewrite flush --hard --allow-root --path=/var/www/html

# 예제 페이지 삭제
wp post delete $(wp post list --post_type=page --name="sample-page" --field=ID --allow-root 2>/dev/null) --force --allow-root 2>/dev/null || true

# My account 메뉴 mypage.html로 연결
wp option update woocommerce_myaccount_page_id 0 --allow-root 2>/dev/null || true

# GitHub에서 커스텀 파일 다운로드
GITHUB_RAW="https://raw.githubusercontent.com/brk-devsec/shop-files/main"

wget -O /var/www/html/index.html   $GITHUB_RAW/index.html
wget -O /var/www/html/login.html   $GITHUB_RAW/login.html
wget -O /var/www/html/mypage.html  $GITHUB_RAW/mypage.html
wget -O /var/www/html/style.css    $GITHUB_RAW/style.css
wget -O /var/www/html/login.css    $GITHUB_RAW/login.css
wget -O /var/www/html/main.js      $GITHUB_RAW/main.js
wget -O /var/www/html/login.js     $GITHUB_RAW/login.js
wget -O /var/www/html/auth.php     $GITHUB_RAW/auth.php

chown apache:apache \
  /var/www/html/index.html \
  /var/www/html/login.html \
  /var/www/html/mypage.html \
  /var/www/html/style.css \
  /var/www/html/login.css \
  /var/www/html/main.js \
  /var/www/html/login.js \
  /var/www/html/auth.php \
  /var/www/html/.htaccess

chmod 644 \
  /var/www/html/index.html \
  /var/www/html/login.html \
  /var/www/html/mypage.html \
  /var/www/html/style.css \
  /var/www/html/login.css \
  /var/www/html/main.js \
  /var/www/html/login.js \
  /var/www/html/auth.php \
  /var/www/html/.htaccess

systemctl enable --now httpd
systemctl restart httpd