# Baseline weaknesses

The Phase 1 environment is deliberately built the way many real organizations
run vendor access. Each weakness below is the baseline for a control added in
Phase 3 and, usually, a detection. Tags `[W#]` appear as comments in the
provisioning scripts.

| Tag | Weakness | Where | Phase 3 control | ATT&CK |
|-----|----------|-------|-----------------|--------|
| W1 | Password-only auth, no MFA on the vendor account | directory config | Phishing-resistant MFA (FIDO2/WebAuthn) | T1078 |
| W2 | Shared vendor account, password never expires | directory config | Named individual accounts; rotation | T1078.002 |
| W3 | Vendor over-permissioned (added to Facilities) | directory config | Least privilege; scoped access | T1078 |
| W4 | Finance share readable by all Domain Users | file server shares | ACL tightening; segmentation | T1039 |
| W5 | Flat network — vendor can reach every host | topology (Phase 2 VPN) | ZTNA / jump host to one app; segmentation | T1021 |
| W6 | Standing access — account always enabled | directory config | Just-in-time enablement | T1078 |
| W7 | No behavioral alerting on vendor logins | SIEM baseline | Detections in `detections/` + honeytokens | — |

## Narrative

CoolAir HVAC monitors rooftop units at Acme Widgets. For convenience, IT created
a single shared account (`v-coolair`) that CoolAir's technicians all use, gave it
a password that never expires, and — when the vendor said they "sometimes need to
check facilities records" — dropped it into the Facilities group. Over time the
network stayed flat, so anything the account could authenticate to, it could
reach. No one built alerting specific to vendor behavior.

This is the environment the attacker inherits when the credential is stolen.
