# Phase 3 — Hardening

Remediates every weakness from `docs/baseline-weaknesses.md` and deploys the
honeytoken. Some controls (phishing-resistant MFA, ZTNA) can't be fully realised
inside a VirtualBox AD lab; those are implemented where possible and described
honestly where not. Saying "here's what I built, here's what I'd add in prod and
why" reads as maturity, not a gap.

## What these scripts do

| Script | Host | Fixes | Control |
|--------|------|-------|---------|
| `01-remediate-identity.ps1` | dc01 | W3, W6, W8 | Least privilege, JIT (disable-by-default), AES-only service account |
| `Enable-VendorAccess.ps1` | dc01 | W6 | Time-boxed JIT enablement with auto-expiry |
| `02-remediate-fs01.ps1` | fs01 | W4, W9 | Tighten Finance ACL, remove service-account local admin, SMB signing |
| `03-deploy-honeytoken.ps1` | dc01 | W7 | Decoy account that fires a critical alert on any use |

Run order: `01`, then `02` (on fs01), then `03`. Re-runnable.

## Controls demonstrated vs. described

**Fully implemented in the lab**
- Least privilege (group + share ACL remediation)
- Just-in-time vendor access (disabled by default; time-boxed enable)
- Kerberoast remediation (AES-only service account; optional domain-wide RC4 off)
- SMB signing
- Honeytoken detection

**Described in the write-up, partially modelled**
- **Phishing-resistant MFA.** Can't be enforced on raw AD logons here. Model it
  with Keycloak/Authentik in front of the vendor's access and require WebAuthn.
  Document the conditional-access intent: managed device + expected geo + MFA.
- **ZTNA / jump host.** Replace the flat reach (W5) with a broker so the vendor
  only ever reaches the one HVAC app. Teleport community edition (session
  recording) or a hardened RDP/SSH jump host demonstrates this; Cloudflare Zero
  Trust free tier is the SaaS version. Host-firewall segmentation (below) is the
  in-lab stand-in.

## Network segmentation (in-lab stand-in for ZTNA)

Represent "vendor reaches one app, nothing else" with host firewall rules. On
dc01, block SMB/LDAP from the attacker/vendor segment; on fs01, allow only the
needed port. Example (run on dc01, elevated), illustrative — scope to your IPs:

```powershell
New-NetFirewallRule -DisplayName "Block vendor segment SMB" -Direction Inbound `
  -Protocol TCP -LocalPort 445 -RemoteAddress 10.10.10.66 -Action Block
```

## After hardening
Go to Phase 4: re-run the Phase 2 attack scripts and record, per step, whether
it's now **blocked** or **detected**. That before/after table is the headline
result of the whole project.
