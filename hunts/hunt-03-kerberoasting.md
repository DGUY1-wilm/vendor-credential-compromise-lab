# Hunt 03 — Kerberoasting

**Hypothesis:** An attacker with any valid domain credential will request
service tickets for SPN accounts using RC4, to crack them offline.

**ATT&CK:** T1558.003 (Kerberoasting)

**Data sources:** Windows Security 4769 (Kerberos service ticket operations) from
dc01. Requires the "Kerberos Service Ticket Operations" audit subcategory (set in
Phase 1 `enable-auditing.ps1`).

## Questions and queries

1. **All RC4 service-ticket requests, excluding machine accounts:**
   ```
   data.win.system.eventID:"4769" AND data.win.eventdata.ticketEncryptionType:"0x17"
   AND NOT data.win.eventdata.serviceName:*$
   ```

2. **Who requested them** — pivot on `data.win.eventdata.ipAddress` and
   `data.win.eventdata.targetUserName`. One account requesting tickets for many
   SPNs in a short window is a strong signal.

3. **Rarity check:** how often does RC4 appear at all? If your estate is
   AES-clean, *every* 0x17 is worth a look. If legacy apps make noise, baseline
   them and alert on the deviation.

## Expected finding (post Phase 2)
A 4769 for the svc-backup SPN with encryption 0x17, requested from the Kali IP by
v-coolair.

## Detection produced
`kerberoasting_rc4_tgs_request.yml` (Wazuh 100100). Remediation in
`harden/01` (AES-only on the service account) removes the crackable path; the
detection stays for defense in depth.

## Notes / what I actually found
_(fill in)_
