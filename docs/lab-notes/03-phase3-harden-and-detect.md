# Lab note — Phase 3 & 4: harden, detect, re-test

**Date:**

## Hardening applied
- [ ] 01-remediate-identity.ps1 (dc01) — W3, W6, W8
- [ ] 02-remediate-fs01.ps1 (fs01) — W4, W9
- [ ] 03-deploy-honeytoken.ps1 (dc01) — W7
- [ ] Detections deployed to Wazuh and verified with wazuh-logtest
- [ ] Segmentation rules applied

## Before / after scorecard (the headline result)

| Attack step | Phase 2 (baseline) | Phase 4 (hardened) | Detection that fired | Time to detect |
|-------------|--------------------|--------------------|----------------------|----------------|
| Recon / share enum | not detected | | | |
| BloodHound | not detected | | 100107 (honeytoken)? | |
| Kerberoast | not detected | blocked (AES) + 100100 | | |
| Lateral + secretsdump | not detected | | 100102 / 100103 | |
| Collection / exfil | not detected | | 100104 | |
| Persistence | not detected | | 100105 / 100106 | |

## One-line result for the README
_e.g. "Breach went from fully undetected to blocked at login, with every
remaining step alerted; mean time to detect under X minutes."_

## What surprised me / limitations
