#!/usr/bin/env bash
set -euo pipefail

TS="$(date -Iseconds)"
D="$(date -Id)"
HOST="$(hostname)"
BASE="$(pwd)"
EVD="$BASE/evidence/$D"
RPT="$BASE/reports/$D"
mkdir -p "$EVD" "$RPT"

log(){ echo "[$(date -Iseconds)] $*" | tee -a "$EVD/_run.log" >/dev/null; }
run(){ local name="$1"; shift; log "RUN $name"; ( "$@" ) 2>&1 | tee "$EVD/${name}.txt" >/dev/null; }

log "START host=$HOST user=$(id -un) uid=$(id -u) ts=$TS"

run 00_identity        bash -lc 'id; whoami; groups; sudo -l'
run 01_system          bash -lc 'uname -a; lsb_release -a 2>/dev/null || true; cat /etc/os-release'
run 02_time            bash -lc 'date -Iseconds; timedatectl 2>/dev/null || true'
run 03_disk            bash -lc 'df -h; sudo du -xhd1 / | sort -h | tail -n 25'
run 04_network         bash -lc 'ip -br a; ip r; resolvectl status 2>/dev/null || cat /etc/resolv.conf'
run 05_listeners       bash -lc 'sudo ss -tulpen'
run 06_services        bash -lc 'systemctl --failed || true; systemctl list-unit-files --state=enabled | head -n 200'
run 07_firewall        bash -lc 'sudo ufw status verbose || true; sudo iptables -S || true; sudo ip6tables -S || true'
run 08_updates_check   bash -lc 'sudo apt-get update -y; apt-get -s upgrade | sed -n "1,200p"'
run 09_packages        bash -lc 'dpkg -l | wc -l; apt-mark showmanual | sed -n "1,200p"'
run 10_logs_errors     bash -lc 'sudo journalctl -p 3 -xb --no-pager | tail -n 200 || true'
run 11_auth            bash -lc 'sudo tail -n 200 /var/log/auth.log 2>/dev/null || true'
run 12_permissions     bash -lc 'sudo find /etc -maxdepth 2 -type f -perm -002 -print | sed -n "1,200p"'
run 13_world_writable  bash -lc 'sudo find / -xdev -type d -perm -0002 -print 2>/dev/null | sed -n "1,200p"'
run 14_suid_sgid       bash -lc 'sudo find / -xdev -type f \( -perm -4000 -o -perm -2000 \) -printf "%m %u:%g %p\n" 2>/dev/null | sort | sed -n "1,200p"'
run 15_cron            bash -lc 'sudo ls -la /etc/cron.* /etc/crontab 2>/dev/null || true'

# Relatório curto (portfólio-friendly)
cat > "$RPT/SECOPS-DAILY.md" <<MD
# Daily SecOps Report — $D ($HOST)

## Identity
- user: $(id -un) (uid=$(id -u))
- sudo: $(sudo -n true 2>/dev/null && echo "cached/ok" || echo "password required (ok)")

## Firewall
- ufw: $(sudo ufw status 2>/dev/null | head -n 1 || echo "ufw not active/available")

## High-signal checks
- listeners: evidence/$(basename "$EVD")/05_listeners.txt
- enabled services: evidence/$(basename "$EVD")/06_services.txt
- errors: evidence/$(basename "$EVD")/10_logs_errors.txt
- auth tail: evidence/$(basename "$EVD")/11_auth.txt
- suid/sgid: evidence/$(basename "$EVD")/14_suid_sgid.txt

## Notes
- All raw outputs are stored under evidence/$D.
MD

log "END"
