#!/bin/bash
# =========================================================
#  Web VM 초기화 스크립트 (Rocky Linux 9 + Apache + WordPress)
#  Terraform templatefile() 로 변수 주입
#
#  templatefile 규칙
#   - $${var}  : terraform 치환 변수
#   - $$VAR    : bash 변수 (중괄호 없이)
# =========================================================
set -ux
exec > /var/log/web-init.log 2>&1

# ---------------------------------------------------------
# 0. SELinux 완화
# ---------------------------------------------------------
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config || true

# ---------------------------------------------------------
# 1. 자동 업데이트 중지
# ---------------------------------------------------------
systemctl stop dnf-automatic.timer packagekit || true
systemctl disable dnf-automatic.timer packagekit || true

# ---------------------------------------------------------
# 2. Apache + PHP + MariaDB 클라이언트 설치 (재시도 최대 60회)
# ---------------------------------------------------------
dnf module reset mariadb -y || true
dnf module enable mariadb:10.11 -y || true

for attempt in $(seq 1 60); do
  if dnf install -y httpd php php-mysqlnd php-curl php-gd php-xml php-mbstring php-json php-zip mariadb wget tar; then
    echo "dnf install succeeded on attempt $attempt"
    break
  fi
  echo "dnf locked/failed, retry $attempt/60 in 15s..."
  sleep 15
done

# 설치 검증
if ! command -v mysql >/dev/null 2>&1; then
  echo "FATAL: package install failed after retries"
  exit 1
fi

# ---------------------------------------------------------
# 3. Apache 설정
# ---------------------------------------------------------
sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf || true
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/httpd/conf/httpd.conf || true

# ---------------------------------------------------------
# 4. DB 대기 (최대 20분)
# ---------------------------------------------------------
echo "Waiting for MariaDB at ${db_host} ..."
for i in $(seq 1 120); do
  if mysqladmin ping -h ${db_host} -u ${mysql_app_user} -p${mysql_app_password} --silent 2>/dev/null; then
    echo "MariaDB reachable."
    break
  fi
  echo "[$i/60] DB not ready, retry in 10s..."
  sleep 10
done

# ---------------------------------------------------------
# 5. WordPress 다운로드 및 배치
# ---------------------------------------------------------
cd /tmp
wget -q https://ko.wordpress.org/latest-ko_KR.tar.gz -O wordpress.tar.gz
tar xzf wordpress.tar.gz
cp -ar wordpress/* /var/www/html/

cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${mysql_database}/g"   /var/www/html/wp-config.php
sed -i "s/username_here/${mysql_app_user}/g"        /var/www/html/wp-config.php
sed -i "s/password_here/${mysql_app_password}/g"    /var/www/html/wp-config.php
sed -i "s/localhost/${db_host}/g"                   /var/www/html/wp-config.php

# ---------------------------------------------------------
# 5-1. Apache 보안 하드닝
# ---------------------------------------------------------
# (A) 기본 하드닝 — nikto 취약점 대응
cat > /etc/httpd/conf.d/hardening.conf << 'HARDEN'
<Directory "/var/www/html">
    Options -Indexes +FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

# Apache 기본 /icons/ 디렉터리 인덱싱 차단
<Directory "/usr/share/httpd/icons">
    Options -Indexes
</Directory>

TraceEnable off
ServerTokens Prod
ServerSignature Off

Header always set X-Content-Type-Options "nosniff"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set Referrer-Policy "no-referrer-when-downgrade"
Header always set Content-Security-Policy "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline'"

<Files "README">
    Require all denied
</Files>
<Files "wp-links-opml.php">
    Require all denied
</Files>
HARDEN

echo "expose_php = Off" > /etc/php.d/99-hardening.ini
rm -f /var/www/html/license.txt /var/www/html/readme.html /var/www/html/wp-config-sample.php 2>/dev/null || true

# (B) HTTP 메서드 제한 — GET/POST/HEAD 만 허용
cat > /etc/httpd/conf.d/methods.conf << 'METHODS'
<Directory "/var/www/html">
    <LimitExcept GET POST HEAD>
        Require all denied
    </LimitExcept>
</Directory>
METHODS

# (C) uploads PHP 실행 차단 — 웹쉘 방어
cat > /etc/httpd/conf.d/uploads-noexec.conf << 'NOEXEC'
<Directory "/var/www/html/wp-content/uploads">
    <FilesMatch "\.(php|php3|php4|php5|php7|phtml|pht)$">
        Require all denied
    </FilesMatch>
</Directory>
NOEXEC

# (D) ModSecurity — Apache WAF 모듈 (OWASP CRS)
for attempt in $(seq 1 30); do
  if dnf install -y mod_security mod_security_crs; then
    echo "modsecurity install ok on attempt $attempt"
    break
  fi
  echo "modsecurity install retry $attempt/30 in 15s..."
  sleep 15
done

if [ -f /etc/httpd/conf.d/mod_security.conf ]; then
  sed -i 's/^SecRuleEngine .*/SecRuleEngine On/' /etc/httpd/conf.d/mod_security.conf || true
fi

# ModSecurity 디버그/감사 로그 파일 사전 생성 (없으면 Apache 기동 실패)
mkdir -p /var/log/httpd
touch /var/log/httpd/modsec_debug.log /var/log/httpd/modsec_audit.log
chown apache:apache /var/log/httpd/modsec_debug.log /var/log/httpd/modsec_audit.log

# ---------------------------------------------------------
# (E) Apache 로그 → syslog(local5) 전송 (Sentinel 웹 공격 탐지용)
# ---------------------------------------------------------
cat > /etc/httpd/conf.d/syslog-logging.conf << 'SYSLOG'
ErrorLog "|/usr/bin/logger -t apache-error -p local5.err"
CustomLog "|/usr/bin/logger -t apache-access -p local5.info" combined
SYSLOG

# ---------------------------------------------------------
# 6. 권한 및 서비스 기동
# ---------------------------------------------------------
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

systemctl enable httpd
systemctl restart httpd

# AMA 설치될 때까지 대기 후 재시작 (최대 5분) — DCR의 local5(Apache 로그) 반영
for i in $(seq 1 30); do
  if systemctl list-units --all | grep -q azuremonitoragent; then
    systemctl restart azuremonitoragent
    echo "AMA restarted"
    break
  fi
  echo "waiting for AMA... $i/30"
  sleep 10
done

# ---------------------------------------------------------
# 7. WP-CLI 설치 + WordPress 초기 설치
# ---------------------------------------------------------
curl -sO https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp

cd /var/www/html
wp core install \
  --url="http://localhost" \
  --title="team602 Lab Shop" \
  --admin_user="admin" \
  --admin_password="${mysql_app_password}" \
  --admin_email="admin@team602.local" \
  --skip-email \
  --allow-root || echo "wp core install skipped"

echo "==== Web init done at $(date) ====" > /var/log/web-init-done.log
