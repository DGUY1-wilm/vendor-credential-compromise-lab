# Lab note — Phase 2: attack against the baseline

**Date:**
**VMs / tools:** kali (nxc, impacket, bloodhound-python, hashcat, evil-winrm), dc01, fs01, siem01

## Objective
Run the full stolen-credential attack chain against the UNHARDENED baseline and
record what Wazuh did and did not detect, step by step.

## Detection scorecard (fill in)

| Step | Technique | ATT&CK | Caught at baseline? | Event IDs seen | Notes |
|------|-----------|--------|---------------------|----------------|-------|
| 1 | Recon / share enum | T1135 | | 4624, 5140/5145 | |
| 2 | BloodHound | T1482 | | | |
| 3 | Kerberoast | T1558.003 | | 4769 (RC4) | |
| 4 | Lateral + secretsdump | T1003 | | 4624/4672, 7045 | |
| 5 | Collection / exfil | T1039 | | 5145 | |
| 6 | Persistence | T1053.005 | | 4698/4720/4732 | |

## What surprised me / lessons learned

## Which steps need a detection in Phase 3
(Everything in the "No" column above.)

## Cleanup done?
- [ ] Removed scheduled task `AcmeUpdater` on fs01
- [ ] Removed local account `svc-helpdesk` on fs01
