# Lab note — Phase 3 & 4: harden, detect, re-test

**Date:** 2026-10-28

## Detections deployed and VERIFIED FIRING
Rules installed into `/var/ossec/etc/rules/local_rules.xml` on siem01 (source of
truth: `detections/wazuh/local_rules.xml`).

**Rule 100100 (Kerberoasting) confirmed firing** against a real 4769 event using
`wazuh-logtest`: matched at **level 12**, description
"Kerberoasting: weak service ticket requested for svc-backup", MITRE
**T1558.003**, "Alert to be generated."

<!-- IMAGE: 05-detection-kerberoast-fires.png -->
<!-- ![Detection fires on the Kerberoast](images/05-detection-kerberoast-fires.png) -->
<!-- wazuh-logtest Phase 3: the real Kerberoast event now matches rule 100100 (level 12, T1558.003). -->

### Two bugs fixed to get it firing (see AI_USAGE.md)
1. Rule matched `ticketEncryptionType` `0x17` only; the real event was
   `0xffffffff`. Fixed to match both.
2. Rules chained off `<if_group>windows>` / `windows_security`, which didn't match
   how events were tagged. Switched to `<decoded_as>json</decoded_as>`.

## Hardening to apply (Phase 4)
- [ ] 01-remediate-identity.ps1 (dc01) — W3, W6, W8
- [ ] 02-remediate-fs01.ps1 (fs01) — W4, W9
- [ ] 03-deploy-honeytoken.ps1 (dc01) — W7
- [ ] Re-run the attack and record blocked vs. detected per step

## Before / after scorecard (headline result)

| Attack step | Phase 2 (baseline) | Phase 4 (hardened) | Detection that fired |
|-------------|--------------------|--------------------|----------------------|
| Recon / logon | logged, not alerted | | 100101 |
| Kerberoast | logged, not alerted | | **100100 (verified)** |
| Lateral + priv | logged, not alerted | | 100102 |
| Collection / exfil | logged, not alerted | | 100104 |

## Infra lesson logged
Wazuh's Vulnerability Detection module filled the SIEM disk (16 GB CVE feed in
`vd_updater`). Cleared it and disabled the module — now automated in
`install-wazuh.sh`. Standard SIEM resource management.
