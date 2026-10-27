# Phase 2 — Attack with the stolen vendor credential

Plays out what an attacker does once CoolAir HVAC's `v-coolair` password has been
stolen, against the **unhardened** Phase 1 baseline. The goal is not just to
"win" — it's to generate realistic telemetry and show how little the baseline
SIEM flags. Phase 3 hardens and detects; Phase 4 re-runs this and measures.

## Safety

- Every script refuses any target outside `10.10.10.0/24` (`assert_lab_target`).
- All data read/exfiltrated is fake and clearly labeled.
- The scenario starts **after** credential theft — nothing here harvests real
  credentials. The "payloads" in the persistence step are benign (write a
  timestamp); they exist only to produce the Windows events a real one would.
- Keep the lab on its isolated internal network.

## Prerequisites

1. Phase 1 lab built and the Wazuh agents reporting.
2. Seed the attack path (adds weaknesses W8/W9):
   - On **dc01** (elevated PowerShell): `C:\vagrant\scripts\dc01\03-seed-attack-paths.ps1`
   - On **fs01** (elevated PowerShell): `C:\vagrant\scripts\fs01\03-seed-localadmin.ps1`
3. Attacker VM up: `vagrant up kali` (see the Vagrantfile).

## The chain

| # | Script | Technique(s) | ATT&CK |
|---|--------|--------------|--------|
| 1 | `01-recon.sh` | Credential validation, host/share/user discovery | T1078.002, T1018, T1135, T1087.002 |
| 2 | `02-bloodhound.sh` | AD attack-path mapping | T1482, T1069.002 |
| 3 | `03-kerberoast.sh` | Roast + offline crack of `svc-backup` | T1558.003 |
| 4 | `04-lateral-move.sh` | Pivot to fs01, dump secrets | T1021.002/.006, T1003 |
| 5 | `05-collect-exfil.sh` | Collect + stage fake sensitive data | T1039, T1560, T1074 |
| 6 | `06-persistence.sh` | Scheduled task + rogue local admin (benign) | T1053.005, T1136.001 |

## Two ways to run it

- **Scripted:** run `attack/scripts/01..06` in order from the Kali box. Fast,
  repeatable, good for re-running in Phase 4.
- **Manual runbook:** `runbook.md` walks each step by hand with expected output
  and the exact events to look for. Do this at least once — the manual pass is
  where you learn what each tool actually touches.

## After the run

Record results in `docs/lab-notes/02-phase2-attack-baseline.md`: for each step,
what the SIEM showed vs. missed. That gap is the justification for every
detection you build in Phase 3. Then **clean up** the persistence artifacts noted
in step 6 before re-imaging or moving on.

## Tooling note

NetExec (`nxc`), Impacket, BloodHound CE, evil-winrm, and hashcat all move
quickly. If a package name or flag has changed since this was written, check
`apt search` / the tool's `--help` and adjust. Tell me what broke and I'll update.
