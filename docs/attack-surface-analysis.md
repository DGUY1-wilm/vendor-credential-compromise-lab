# Attack Surface Analysis — Vendor Access, Before vs. After

How the third-party access path looks to an external attacker before hardening
and after. Written for the attack-surface-management angle: the goal is to show
that the strongest control is often *removing* something from view, not detecting
its abuse after the fact.

> Honesty note: the lab runs on an isolated internal network, so there is no real
> internet-facing surface to scan. This analysis models the external perspective
> using the same techniques against the lab's vendor-facing entry point, and
> describes how each item would present on a real perimeter. The methodology and
> the before/after logic are the transferable parts.

---

## 1. The attacker's external view — methodology

An attacker assessing a target's vendor access footprint works from the outside
in, with no credentials, using passive and active discovery:

1. **Passive footprinting** — certificate transparency logs, DNS, search engines,
   and breach/infostealer dumps to find vendor portals, VPN gateways, and leaked
   credentials. (In a real engagement: crt.sh, DNS enumeration, credential-leak
   feeds.)
2. **Service discovery** — port and service scanning of discovered hosts:
   ```
   nmap -sV -Pn -p- <target>
   ```
3. **Web/endpoint fingerprinting** — identify exposed login portals, VPN
   endpoints, RDP/SMB, management interfaces:
   ```
   httpx -title -tech-detect -status-code -l hosts.txt
   ```
4. **Known-vulnerability checks** — template scanning of exposed services:
   ```
   nuclei -l live-hosts.txt -severity medium,high,critical
   ```

The output of this phase is the **attack surface**: every service an unauthenticated
outsider can see and reach.

---

## 2. Before hardening — the exposed surface

In the baseline design, vendor access is a password-only remote entry point onto a
flat network. To an external attacker this presents as:

| Exposed item | How it presents | Why it matters |
|--------------|-----------------|----------------|
| Vendor remote-access endpoint | A login portal / VPN / exposed RDP reachable from anywhere | Single password away from internal access |
| No MFA | Login accepts username + password only | Stolen credential works immediately |
| Flat internal reach | Once in, every internal host is routable | Entire estate is "behind" one door |
| Over-exposed shares | Sensitive data reachable from any authenticated context | High-value target with low effort |

**Surface characteristics:** large and credential-only. The entire corporate
network sits behind a single authentication boundary that a stolen password
defeats. Discovery is easy; exploitation needs only the credential (which the
infostealer scenario supplies).

**Attacker effort to reach crown jewels:** low. One credential → network → file
server → data.

---

## 3. After hardening — the reduced surface

The Phase 3 controls change *what is visible and reachable*, not just what is
logged:

| Control | Effect on the surface |
|---------|-----------------------|
| ZTNA / jump host (F-05) | The broad remote entry point disappears. The vendor reaches **one application** through a broker; nothing else is routable or even visible. |
| Phishing-resistant MFA (F-01) | The remaining entry point no longer yields to a stolen password alone. |
| Segmentation | Even post-authentication, lateral reach is cut to the single sanctioned host. |
| Just-in-time access (F-06) | The entry point is *closed by default* — unreachable outside approved windows. |
| Honeytoken (F-07) | Enumeration of what remains now trips a high-confidence alert. |

**Surface characteristics:** small, credential-resistant, and time-bounded. The
single exposed service is reachable only during approved windows, only with
phishing-resistant MFA, and leads only to one application. The crown jewels are no
longer "behind one door" — there is no door to them from the vendor path at all.

**Attacker effort to reach crown jewels:** high and noisy. Each remaining step is
either blocked or alerts.

---

## 4. Before/after at a glance

| Dimension | Before | After |
|-----------|--------|-------|
| Internet-facing entry points (vendor path) | 1 broad (VPN/RDP, flat) | 1 narrow (brokered single app) |
| Authentication | Password only | Phishing-resistant MFA |
| Availability of the entry point | Always on | JIT, time-boxed |
| Internal reach after entry | Entire estate | One sanctioned host |
| Enumeration of what remains | Silent | Trips honeytoken alert |
| Effort to reach sensitive data | Low | High + detected |

---

## 5. Takeaway for a defender

Detection (Phase 3 `detections/`) is essential, but the cheapest risk reduction
here came from **shrinking the surface** — removing the flat remote entry point so
there is less to attack, authenticate against, or monitor in the first place. In
attack-surface terms: the best-defended service is the one an outsider can no
longer see.

**Methodology note:** the same external-discovery workflow (passive footprinting →
service discovery → fingerprinting → vuln checks) is how you would validate the
"after" state on a real perimeter — scan from outside and confirm the broad entry
point is genuinely gone, not just reconfigured.
