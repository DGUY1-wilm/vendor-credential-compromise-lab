# Third-Party Credential Compromise: Attack & Defense Lab

Simulating the theft and abuse of a vendor's credentials against an enterprise,
then building the controls and detections that stop it. Maps to MITRE ATT&CK
**T1078 (Valid Accounts)** and **T1199 (Trusted Relationship)** — the pattern
behind the 2013 Target breach and the 2024 Snowflake-related intrusions.

> **One-line result:** _(fill in after Phase 4)_ — e.g. "The simulated breach
> went from undetected to blocked at login, with lateral movement alerted in
> under two minutes."

## The scenario

**Acme Widgets** (fictional) outsources HVAC monitoring to **CoolAir HVAC**, a
vendor with a remote-access account. An infostealer harvests that account's
password. This lab plays out what happens next — first against a typical weak
baseline, then against a hardened one.

## Phases

| Phase | What happens | Status |
|-------|--------------|--------|
| 1 | Build the vulnerable corporate baseline | scripts ready |
| 2 | Attack with the stolen vendor credential; show the SIEM sees almost nothing | scripts + runbook ready |
| 3 | Harden (least privilege, JIT, AES, honeytoken) + detections & hunts | ready |
| 4 | Re-attack; measure what's blocked, what's detected, how fast | planned |

## Deliverables

- **Threat-hunting & detection report** — the attack (`attack/`), hypothesis-driven hunts (`hunts/`), Sigma + Wazuh rules (`detections/`)
- **Attack-surface write-up** — before vs. after hardening (`docs/attack-surface-analysis.md`)
- **Third-party risk assessment** — executive-facing, NIST CSF 2.0 + 800-53 (`risk-assessment/`)
- **Incident response playbook** — suspected compromised third-party credential (`playbooks/`)

## Lab topology (Phase 1)

```
VirtualBox internal network "acme-corp" — 10.10.10.0/24 (isolated)
  dc01    10.10.10.10   Windows Server 2022   AD DS, DNS (acme.lab)
  fs01    10.10.10.11   Windows Server 2022   File shares + fake data
  siem01  10.10.10.20   Ubuntu 22.04          Wazuh (indexer/manager/dashboard)
```

Windows hosts run Sysmon (SwiftOnSecurity config) and the Wazuh agent. The
attacker VM and vendor segment arrive in Phase 2.

## Requirements

- VirtualBox 7.x, Vagrant 2.4+, ~16 GB RAM free, ~60 GB disk
- `vagrant plugin install vagrant-reload`

## Build it

```bash
cd lab
vagrant up siem01          # bring the SIEM up first so agents can enroll
vagrant up dc01            # promotes to DC, reboots, builds the directory
vagrant up fs01            # joins the domain, creates shares + fake data
```

Wazuh dashboard: `https://127.0.0.1:8443` (credentials in `lab/.secrets/`,
which is git-ignored). Confirm `dc01` and `fs01` show as active agents.

## Safety

This environment is **intentionally vulnerable** and contains only fake,
clearly-labeled data. Keep it on the isolated internal network. Never bridge it
to a real network, and never reuse these lab passwords anywhere.

## Repository layout

```
lab/            Vagrantfile + provisioning scripts
docs/           Baseline weaknesses, architecture notes, lab notes
detections/     Sigma rules + Wazuh rule translations
hunts/          Hypothesis-driven threat hunts
playbooks/      Incident response
risk-assessment/  NIST-mapped vendor access risk assessment
```

## Credits

Built with open-source tooling: Wazuh, Sysmon, the SwiftOnSecurity Sysmon
config, and the Sigma project. Detections reference the MITRE ATT&CK framework.
