# Incident Response Playbook
### Suspected Compromised Third-Party / Vendor Credential

**Owner:** SOC / Incident Response
**Scope:** Any sign that a vendor or third-party account has been stolen or
misused (alerts from `detections/`, threat-intel credential-leak notice, vendor
breach notification, or anomalous vendor activity).
**Lifecycle:** Aligns with the SANS incident-handling process and NIST SP 800-61.

> This playbook is written against the lab (`acme.lab`, accounts `v-*`/`svc-*`,
> hosts dc01/fs01, Wazuh SIEM). In production, replace names with your asset and
> identity inventory.

---

## Severity guide

| Level | Example trigger | Target response start |
|-------|-----------------|-----------------------|
| **SEV-1 Critical** | Honeytoken hit (Wazuh 100107); confirmed admin access via vendor path | Immediate |
| **SEV-2 High** | Vendor account off-scope logon + sensitive share access; secretsdump signature | < 30 min |
| **SEV-3 Medium** | Single anomalous vendor logon (new IP / off-hours), no further activity | < 2 hours |

---

## 1. Preparation (before an incident)

- Maintain the third-party access inventory (owner, systems, justification).
- Keep vendor emergency contacts and breach-notification SLAs on hand.
- Ensure the `detections/` rules are deployed and firing (verify with
  `wazuh-logtest`).
- Pre-stage the containment commands below so they can be run under pressure.
- Confirm who is authorised to disable a vendor account and notify the vendor.

## 2. Detection & analysis

**Triage questions**
1. Which account, and which vendor does it belong to?
2. What fired — which detection, at what time, from what source IP?
3. Is the source IP/device expected for this vendor? Within an approved
   maintenance window?
4. What has the account done since the first anomalous event?

**Scope the activity (Wazuh queries)**
```
# All activity for the suspect account
data.win.eventdata.targetUserName:"<account>"

# Hosts reached
data.win.eventdata.targetUserName:"<account>" AND data.win.system.eventID:"4624"

# Sensitive data touched
data.win.eventdata.subjectUserName:"<account>" AND data.win.system.eventID:"5145"

# Privilege / escalation signals
data.win.system.eventID:("4672" OR "4769" OR "7045")
```

**Decide:** false positive (newly authorised access → document and tune) vs. true
positive (→ containment). When uncertain, treat as true positive and contain;
reversing a disable is cheap, undoing a breach is not.

## 3. Containment

Order matters — cut access first, preserve evidence alongside.

1. **Disable the account** (not delete — preserve it for investigation):
   ```powershell
   Disable-ADAccount -Identity <account>
   ```
2. **Revoke active sessions and tickets:**
   ```powershell
   # Force Kerberos tickets to be re-issued (invalidates stolen TGTs on next cycle)
   Get-ADUser <account> | Set-ADUser -Replace @{msDS-KeyCredentialLink=$null} -ErrorAction SilentlyContinue
   # Kill live sessions on affected hosts (example for fs01)
   # quser / logoff <id> on the host, or isolate the host (step 4)
   ```
   For federated/IdP access, revoke tokens and sign-in sessions at the IdP.
3. **Reset the credential** and any secrets the account could have exposed —
   including service accounts it could reach (e.g. svc-backup) and local secrets
   on hosts it touched.
4. **Isolate affected hosts** if lateral movement or dumping is confirmed
   (network-isolate fs01; snapshot first for forensics).
5. **Block the attacker source IP** at the perimeter / host firewall.

## 4. Eradication

- Remove persistence planted by the attacker. From the lab attack, check for and
  remove:
  ```powershell
  schtasks /query /tn AcmeUpdater           # delete if present
  Get-LocalUser svc-helpdesk                 # remove rogue account if present
  ```
- Hunt for other persistence: new accounts, new services (7045), new scheduled
  tasks (4698), new admin-group members (4732), modified run keys.
- Confirm the escalation path used is closed (apply `harden/` remediations if not
  already done).
- Validate no other accounts were compromised from dumped credentials.

## 5. Recovery

- Re-enable access only after: credential reset, MFA enforced, privileges
  right-sized, and monitoring confirmed.
- Prefer just-in-time re-enablement (`harden/Enable-VendorAccess.ps1`) over
  restoring standing access.
- Monitor the account and affected hosts at heightened sensitivity for a defined
  period.
- Confirm business function (HVAC monitoring) is restored through the sanctioned
  path only.

## 6. Post-incident

- **Timeline:** first malicious action → detection → containment. Capture
  mean-time-to-detect and mean-time-to-contain.
- **Root cause:** which control gap allowed entry (map to a finding in
  `risk-assessment/`).
- **Lessons learned / actions:** new or tuned detections, control changes, vendor
  conversations.
- **Vendor notification:** inform CoolAir per contract; confirm they have
  remediated the source of the credential theft.
- **Evidence retention:** preserve logs, snapshots, and this record per policy.

---

## Quick reference — containment one-liners

```powershell
Disable-ADAccount -Identity <account>                      # cut access
# reset password
Set-ADAccountPassword -Identity <account> -Reset -NewPassword (Read-Host -AsSecureString)
# remove lab persistence
schtasks /delete /tn AcmeUpdater /f
net user svc-helpdesk /del
```

## ATT&CK → response mapping

| Observed (ATT&CK) | Detection | Containment priority |
|-------------------|-----------|----------------------|
| T1078.002 Valid Accounts | 100101 / off-scope logon | Disable account, revoke sessions |
| T1558.003 Kerberoasting | 100100 / 4769 RC4 | Reset service account, enforce AES |
| T1003 Credential Dumping | 100103 / 7045 | Isolate host, reset exposed secrets |
| T1136.001 / T1053.005 Persistence | 100105 / 100106 | Remove account/task, hunt for more |
