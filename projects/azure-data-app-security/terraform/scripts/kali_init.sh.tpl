#!/bin/bash
# =========================================================
#  Kali VM 초기화 스크립트 (공격자)
#  Terraform templatefile() 로 변수 주입
#
#  templatefile 규칙
#   - $${var}  : terraform 치환 변수
#   - $$VAR    : bash 변수 (중괄호 없이)
#
#  주입 변수: admin_username, web_public_ip, db_private_ip
# =========================================================
set -ux
exec > /var/log/kali-init.log 2>&1

# ---------------------------------------------------------
# 1. 패키지 목록 갱신 + 공격 도구 설치 (재시도 최대 20회)
# ---------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

for attempt in $(seq 1 20); do
  if apt-get update -y; then
    echo "apt update succeeded on attempt $attempt"
    break
  fi
  echo "apt update failed, retry $attempt/20 in 15s..."
  sleep 15
done

# 핵심 공격 도구
for attempt in $(seq 1 20); do
  if apt-get install -y nmap hydra nikto sqlmap wpscan curl netcat-traditional dnsutils; then
    echo "tool install succeeded on attempt $attempt"
    break
  fi
  echo "apt install failed/locked, retry $attempt/20 in 15s..."
  sleep 15
done

# ---------------------------------------------------------
# 2. rockyou.txt 압축 해제 (hydra brute force 용)
# ---------------------------------------------------------
if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
  gunzip -k /usr/share/wordlists/rockyou.txt.gz || true
fi

echo "==== Kali init done at $(date) ====" > /var/log/kali-init-done.log
