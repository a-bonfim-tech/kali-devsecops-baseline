#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DAY="$(date -I)"
EVD="$BASE_DIR/evidence/$DAY"

mkdir -p "$EVD"

date -Iseconds | tee "$EVD/timestamp.txt" >/dev/null
uname -a | tee "$EVD/uname.txt" >/dev/null
lsb_release -a 2>/dev/null | tee "$EVD/lsb_release.txt" >/dev/null || true
whoami | tee "$EVD/whoami.txt" >/dev/null
id | tee "$EVD/id.txt" >/dev/null

# rede
ip a | tee "$EVD/ip_a.txt" >/dev/null
ip r | tee "$EVD/ip_r.txt" >/dev/null
resolvectl status 2>/dev/null | tee "$EVD/resolvectl_status.txt" >/dev/null || true
cat /etc/resolv.conf | tee "$EVD/resolv.conf.txt" >/dev/null

# firewall
sudo ufw status verbose | tee "$EVD/ufw_status_verbose.txt" >/dev/null
sudo ufw show raw | tee "$EVD/ufw_show_raw.txt" >/dev/null || true

# storage
df -h | tee "$EVD/df_h.txt" >/dev/null
lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,LABEL,MODEL | tee "$EVD/lsblk.txt" >/dev/null

# listeners (visão rápida)
ss -tulpn | tee "$EVD/ss_tulpn.txt" >/dev/null || true

echo "OK: evidências em $EVD"
