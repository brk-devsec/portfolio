#!/bin/bash
# =========================================================
#  Bastion VM 초기화 스크립트
#  - id_rsa 개인키를 cloud-init 로 주입
#  - Web/DB VM SSH 점프 서버 역할
# =========================================================
set -eux
exec > /var/log/bastion-init.log 2>&1

# ---------------------------------------------------------
# 0. SELinux 완화
# ---------------------------------------------------------
setenforce 0 || true
sed -i 's/^SELINUX=enforcing/SELINUX=permissive/' /etc/selinux/config || true

# ---------------------------------------------------------
# 1. SSH 개인키 배치 (terraform 이 주입)
# ---------------------------------------------------------
mkdir -p /home/${admin_username}/.ssh
cat > /home/${admin_username}/.ssh/id_rsa << 'SSHKEY'
${private_key}
SSHKEY

chmod 600 /home/${admin_username}/.ssh/id_rsa
chown -R ${admin_username}:${admin_username} /home/${admin_username}/.ssh

echo "==== Bastion init done at $(date) ====" > /var/log/bastion-init-done.log