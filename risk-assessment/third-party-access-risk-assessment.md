# Third-Party Access Risk Assessment
### Acme Widgets, Inc. — Vendor Remote Access (CoolAir HVAC)

**Prepared by:** Daniel Guy
**Date:** 2026-10-27
**Classification:** Internal — Confidential
**Framework alignment:** NIST Cybersecurity Framework (CSF) 2.0; NIST SP 800-53 Rev. 5

---

## 1. Executive summary

Acme Widgets grants a third-party HVAC vendor, CoolAir, remote access to its
corporate environment for rooftop-unit monitoring. This assessment evaluated the
risk that a stolen vendor credential could be used to reach the wider enterprise
— the pattern behind several major breaches, including Target (2013, HVAC
vendor) and the 2024 Snowflake-related intrusions (stolen customer credentials
without MFA).

We modelled the full attack in a controlled lab: beginning with a single stolen
vendor password and ending with administrative access to a file server, theft of
sensitive data, and persistence. **At baseline the entire attack succeeded with
effectively no detection.**

The root causes are not exotic. They are the ordinary ways vendor access
accumulates risk over time: no multi-factor authentication, a shared account with
standing access, excessive privileges, a flat network, and no monitoring tuned to
third-party behaviour. Each is individually common; together they turn one stolen
password into an enterprise compromise.

Nine findings are documented below, two rated **Critical** and six **High**. All
are remediable with controls Acme already owns or can adopt at low cost. The
prioritised roadmap in Section 5 closes the two Critical findings within 30 days.

### Risk summary

| Severity | Count | Findings |
|----------|-------|----------|
| Critical | 2 | F-01 (no MFA), F-05 (flat network) |
| High | 6 | F-02, F-03, F-04, F-07, F-08, F-09 |
| Medium | 1 | F-06 (standing access) |

---

## 2. Scope and methodology

**In scope:** CoolAir HVAC's remote-access account and the corporate systems
reachable from it (domain controller, file server, department shares).

**Out of scope:** Acme's full application estate, physical security, other vendors
(this assessment is a template that should be repeated per vendor).

**Method:** Threat-led. We built a representative environment, then executed a
realistic intrusion from a stolen vendor credential, mapping each step to MITRE
ATT&CK. Findings are drawn from what actually worked, and each is rated for
likelihood and business impact.

**Risk rating** = Likelihood × Impact, using the matrix:

| | Impact: Low | Impact: Moderate | Impact: High |
|---|---|---|---|
| **Likelihood: High** | Medium | High | Critical |
| **Likelihood: Moderate** | Low | Medium | High |
| **Likelihood: Low** | Low | Low | Medium |

---

## 3. Attack narrative (what we proved)

A single stolen password for the shared vendor account `v-coolair` was enough to:
authenticate from an unmanaged attacker host; enumerate the directory and
discover an over-privileged service account; harvest and crack that account's
password offline (Kerberoasting); use it to gain administrator rights on the file
server; read payroll and vendor-payment data exposed to all staff; and install
persistence. None of these steps raised an alert in the baseline environment.

Full technical detail is in `attack/runbook.md`; this section is the business-level
summary for readers who will not run the lab.

---

## 4. Findings

Each finding lists the business impact, the risk rating, the framework references,
and the recommended control.

### F-01 — No multi-factor authentication on vendor access **[CRITICAL]**
- **What:** The vendor account authenticates with a password alone.
- **Business impact:** A password stolen by malware, phishing, or reuse grants
  immediate access. This single control would have stopped the modelled attack at
  step one.
- **Likelihood:** High — infostealer-harvested credentials are traded at scale.
  **Impact:** High.
- **CSF 2.0:** PR.AA (Identity Management, Authentication & Access Control).
  **800-53:** IA-2(1)(2) (MFA), AC-17 (Remote Access).
- **Recommendation:** Require phishing-resistant MFA (FIDO2/WebAuthn) for all
  third-party access. Front vendor access with an identity provider that enforces
  it.

### F-05 — Flat network allows unrestricted lateral reach **[CRITICAL]**
- **What:** Once authenticated, the vendor account can reach every host, not just
  the one system it needs.
- **Business impact:** Converts any foothold into enterprise-wide exposure; this
  is what let a file-server compromise follow from an HVAC login.
- **Likelihood:** High. **Impact:** High.
- **CSF 2.0:** PR.AA, PR.IR (Technology Infrastructure Resilience).
  **800-53:** AC-3 (Access Enforcement), SC-7 (Boundary Protection), AC-4.
- **Recommendation:** Zero-trust network access — the vendor reaches only the
  specific HVAC application through a broker/jump host, nothing else. Segment
  vendor-reachable systems from core infrastructure.

### F-02 — Shared vendor account with non-expiring password **[HIGH]**
- **What:** One account is shared by all CoolAir technicians; its password never
  expires.
- **Business impact:** No individual accountability, no clean way to revoke one
  person's access, and a long-lived secret with more time to leak.
- **Likelihood:** Moderate. **Impact:** High.
- **CSF 2.0:** PR.AA, GV.SC (Supply Chain Risk Management).
  **800-53:** AC-2 (Account Management), IA-2, IA-5 (Authenticator Management).
- **Recommendation:** Named individual accounts per technician; enforce rotation;
  deprovision on vendor staff departure (require the vendor to notify Acme).

### F-03 — Vendor account over-privileged **[HIGH]**
- **What:** The HVAC account holds group membership beyond its function.
- **Business impact:** Widens what a stolen credential can touch.
- **Likelihood:** Moderate. **Impact:** Moderate–High.
- **CSF 2.0:** PR.AA. **800-53:** AC-6 (Least Privilege), AC-5.
- **Recommendation:** Reduce to the minimum required; review quarterly.

### F-04 — Sensitive data exposed to all staff **[HIGH]**
- **What:** The Finance share (vendor payments, bank details) is readable by every
  domain user.
- **Business impact:** Any compromised account — vendor or employee — can read
  financial data; supports fraud and further targeting.
- **Likelihood:** High. **Impact:** Moderate.
- **CSF 2.0:** PR.DS (Data Security). **800-53:** AC-3, AC-6, MP-2.
- **Recommendation:** Restrict shares to the owning department; review access
  recertification.

### F-06 — Standing (always-on) vendor access **[MEDIUM]**
- **What:** The account is permanently enabled, including outside maintenance
  windows.
- **Business impact:** An always-open door; most of the time the access isn't even
  needed.
- **Likelihood:** Moderate. **Impact:** Moderate.
- **CSF 2.0:** PR.AA. **800-53:** AC-2(5), AC-17.
- **Recommendation:** Just-in-time access — disabled by default, enabled for
  approved, time-boxed windows only.

### F-07 — No monitoring of third-party activity **[HIGH]**
- **What:** No detection tuned to vendor-account behaviour; the baseline SIEM
  caught none of the attack.
- **Business impact:** Breaches go undiscovered for long periods, increasing cost
  and scope.
- **Likelihood:** High. **Impact:** High.
- **CSF 2.0:** DE.CM (Continuous Monitoring), DE.AE (Adverse Event Analysis).
  **800-53:** AU-6, SI-4 (System Monitoring), CA-7.
- **Recommendation:** Behavioural detections for vendor/service accounts
  (implemented in `detections/`); honeytokens for high-confidence alerting;
  credential-leak monitoring for vendor domains.

### F-08 — Weak service-account credential (Kerberoastable) **[HIGH]**
- **What:** A service account with a registered service name uses a guessable
  password and permits legacy (RC4) encryption, allowing offline cracking.
- **Business impact:** Any authenticated user — including a stolen vendor account
  — can escalate privilege.
- **Likelihood:** Moderate. **Impact:** High.
- **CSF 2.0:** PR.AA. **800-53:** IA-5, AC-6.
- **Recommendation:** Group-managed service accounts (long, auto-rotated
  passwords); enforce AES; alert on RC4 ticket requests.

### F-09 — Service account over-privileged **[HIGH]**
- **What:** The service account is a local administrator on the file server.
- **Business impact:** A cracked service password yields server admin and
  credential-dumping capability.
- **Likelihood:** Moderate. **Impact:** High.
- **CSF 2.0:** PR.AA. **800-53:** AC-6, AC-5.
- **Recommendation:** Remove standing admin rights; grant only what the service
  requires.

---

## 5. Prioritised remediation roadmap

Sequenced by risk reduction per unit of effort, for a non-technical sponsor.

### Immediate (0–30 days) — close the Critical findings
1. **Enforce phishing-resistant MFA on all vendor access** (F-01).
2. **Restrict vendor access to the single required system** via a jump host or
   ZTNA broker; begin network segmentation (F-05).
3. **Lock down the exposed Finance share** (F-04) — low effort, immediate benefit.

### Short-term (30–90 days) — reduce the High findings
4. Replace the shared account with named, rotated vendor identities (F-02).
5. Right-size vendor and service-account privileges (F-03, F-09).
6. Remediate the Kerberoastable account: gMSA + AES (F-08).
7. Deploy third-party behavioural detections and honeytokens (F-07).

### Medium-term (90–180 days) — mature the programme
8. Just-in-time access for all vendors (F-06).
9. Quarterly vendor access recertification; contractual security requirements
   (MFA, breach notification SLAs, offboarding notice).
10. Extend this assessment to every other third party with access.

---

## 6. Framework coverage summary

| CSF 2.0 Function | Addressed by |
|------------------|--------------|
| **Govern (GV.SC)** | Vendor inventory, contractual requirements, recertification (roadmap 9–10) |
| **Identify (ID.AM/RA)** | Third-party access inventory, this assessment |
| **Protect (PR.AA/DS/IR)** | MFA, least privilege, segmentation, JIT, data ACLs (F-01–06, 08, 09) |
| **Detect (DE.CM/AE)** | Behavioural detections, honeytokens (F-07) |
| **Respond (RS)** | IR playbook — see `playbooks/` |
| **Recover (RC)** | Recovery steps in the IR playbook |

---

## 7. Limitations

This assessment is based on a representative lab model, not Acme's production
environment, and on the postings and configuration reviewed. Findings should be
validated against the live environment. MFA and ZTNA were modelled rather than
fully enforced in the lab; their recommendation stands on established practice.
This is not legal advice; contractual and regulatory obligations should be
reviewed with counsel.
