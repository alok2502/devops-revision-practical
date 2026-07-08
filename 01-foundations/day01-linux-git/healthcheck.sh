#!/usr/bin/env bash
# healthcheck.sh — quick system triage report
set -euo pipefail

DISK_THRESHOLD=80   # warn above this % used
LOG_FILE="/var/log/syslog"

echo "===== HEALTH CHECK: $(hostname) @ $(date '+%F %T') ====="

echo -e "\n--- Uptime & Load ---"
uptime

echo -e "\n--- Memory ---"
free -h

echo -e "\n--- Disk usage (warn > ${DISK_THRESHOLD}%) ---"
df -hP | awk -v t="$DISK_THRESHOLD" 'NR==1{print; next}
  {gsub(/%/,"",$5); status=($5+0 >= t) ? "  <-- WARN" : ""; print $0 status}'

echo -e "\n--- Top 5 by CPU ---"
ps -eo pid,user,%cpu,comm --sort=-%cpu | head -6

echo -e "\n--- Top 5 by Memory ---"
ps -eo pid,user,%mem,comm --sort=-%mem | head -6

echo -e "\n--- Recent errors in ${LOG_FILE} ---"
if [[ -r "$LOG_FILE" ]]; then
  count=$(grep -iE 'error|fail|critical' "$LOG_FILE" 2>/dev/null | wc -l)
  echo "matches: $count"
  grep -iE 'error|fail|critical' "$LOG_FILE" 2>/dev/null | tail -5 || true
else
  echo "cannot read $LOG_FILE (try: sudo $0)"
fi

echo -e "\n===== END ====="
