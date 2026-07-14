#!/bin/bash
# =========================================================
#  DB VM 초기화 스크립트 (Rocky Linux 9 + MariaDB)
#  Terraform templatefile() 로 변수 주입
#
#  templatefile 규칙
#   - $${var}  : terraform 치환 변수
#   - $$VAR    : bash 변수 (중괄호 없이)
#   - $${...}  : bash 배열 이스케이프
# =========================================================
set -ux
exec > /var/log/db-init.log 2>&1

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
# 2. MariaDB 설치 (RPM lock 풀릴 때까지 재시도, 최대 30회)
# ---------------------------------------------------------
dnf module reset mariadb -y || true
dnf module enable mariadb:10.11 -y || true

for attempt in $(seq 1 60); do
  if dnf install -y mariadb-server mariadb; then
    echo "dnf install succeeded on attempt $attempt"
    break
  fi
  echo "dnf locked/failed, retry $attempt/60 in 15s..."
  sleep 15
done

# 설치 검증 - mysql 없으면 중단
if ! command -v mysql >/dev/null 2>&1; then
  echo "FATAL: MariaDB install failed after retries"
  exit 1
fi

systemctl enable mariadb
systemctl start mariadb

# ---------------------------------------------------------
# 3. 로깅 설정
# ---------------------------------------------------------
cat > /etc/my.cnf.d/zz-lab-audit.cnf << 'CNF'
[mariadb]
bind-address = 0.0.0.0

plugin_load_add               = server_audit
server_audit                  = FORCE_PLUS_PERMANENT
server_audit_logging          = ON
server_audit_events           = CONNECT,QUERY,TABLE
server_audit_output_type      = syslog
server_audit_syslog_ident     = mariadb-audit
server_audit_syslog_facility  = LOG_LOCAL6
server_audit_syslog_priority  = LOG_INFO
server_audit_query_log_limit  = 1024

general_log       = 1
general_log_file  = /var/log/mariadb/general.log
log_output        = FILE
CNF

mkdir -p /var/log/mariadb
touch /var/log/mariadb/general.log
chown -R mysql:mysql /var/log/mariadb

systemctl restart mariadb

# ---------------------------------------------------------
# 4. rsyslog
# ---------------------------------------------------------
cat > /etc/rsyslog.d/49-mariadb-audit.conf << 'RSYS'
local6.*    /var/log/mariadb/audit.log
RSYS
systemctl restart rsyslog || true

# ---------------------------------------------------------
# 5. 계정 / DB / 권한  (sudo mysql = root 소켓 인증)
# ---------------------------------------------------------
sudo mysql <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${mysql_root_password}';
CREATE DATABASE IF NOT EXISTS ${mysql_database} CHARACTER SET utf8mb4;
CREATE USER IF NOT EXISTS '${mysql_app_user}'@'%' IDENTIFIED BY '${mysql_app_password}';
GRANT ALL PRIVILEGES ON ${mysql_database}.* TO '${mysql_app_user}'@'%';
FLUSH PRIVILEGES;
SQL

# ---------------------------------------------------------
# 6. 테이블 + 샘플 데이터 50건  (root 계정으로 INSERT)
# ---------------------------------------------------------
sudo mysql -u root -p${mysql_root_password} ${mysql_database} <<'SQL'
CREATE TABLE IF NOT EXISTS personal_info (
  id       INT AUTO_INCREMENT PRIMARY KEY,
  name     VARCHAR(50)  NOT NULL,
  ssn      VARCHAR(20)  NOT NULL,
  phone    VARCHAR(20),
  email    VARCHAR(100),
  address  VARCHAR(200),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SQL

REGIONS=("강남구" "마포구" "종로구" "송파구" "용산구")
for i in $(seq 1 50); do
  IDX=$(printf "%03d" "$i")
  YY=$(printf "%02d" $((RANDOM % 30 + 70)))
  MM=$(printf "%02d" $((RANDOM % 12 + 1)))
  DD=$(printf "%02d" $((RANDOM % 28 + 1)))
  GENDER=$((RANDOM % 4 + 1))
  SERIAL=$(printf "%06d" $((RANDOM % 1000000)))
  PHONE="010-$(printf "%04d" $((RANDOM % 10000)))-$(printf "%04d" $((RANDOM % 10000)))"
  REGION=$${REGIONS[$((RANDOM % 5))]}
  sudo mysql -u root -p${mysql_root_password} ${mysql_database} -e "INSERT INTO personal_info (name, ssn, phone, email, address) VALUES ('사용자$IDX', '$YY$MM$DD-$GENDER$SERIAL', '$PHONE', 'user$IDX@example.com', '서울시 $REGION 테스트로 $i');"
done

echo "==== DB init done at $(date) ====" >> /var/log/db-init-done.log
sudo mysql -u root -p${mysql_root_password} -e "SELECT COUNT(*) AS rows_in_personal_info FROM ${mysql_database}.personal_info;" >> /var/log/db-init-done.log
