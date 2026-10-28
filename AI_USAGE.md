# AI Usage & Transparency

This project was built with AI assistance (Anthropic's Claude), and I'm
documenting that openly. How you use a tool matters more than whether you use
one, so this file records what the AI produced versus what I did myself.

**My role in one line:** I designed the project, made the decisions, built and
ran the entire environment on my own hardware, executed the attack, validated the
detections, and debugged every real-world problem along the way. The AI
accelerated the writing of code and documentation; it did not run the lab or
produce the results, and much of its first-pass code was wrong until I ran it and
fixed it.

Understanding every file well enough to explain it in an interview was a
requirement, not an afterthought.

## Task-by-task breakdown

| Task | What the AI did | What I did |
|------|-----------------|------------|
| Project scope & threat model | Framed it around MITRE T1078 / T1199 and the Target / Snowflake precedents | Chose the topic and goal; decided on one flagship project with multiple deliverables |
| Lab design | Wrote the Vagrantfile and provisioning scripts (AD, file server, SIEM, attacker) | Specified the stack and topology; reviewed the design; ran every build |
| Building the lab | Provided commands and expected output | Installed VirtualBox/Vagrant; built all 4 VMs; hit and fixed real issues (PATH, reboot loops, agent enrollment, disk exhaustion) |
| Attack chain | Wrote the attack scripts and runbook; mapped steps to ATT&CK | Ran the full chain end to end from Kali; recovered from tool failures; captured the evidence |
| Detections | Authored the Sigma + Wazuh rules | Deployed them, found they didn't fire, and tuned them against real events until they did |
| Threat hunts | Drafted 3 hypothesis-driven hunts with queries | Reviewed; to be run against the live data |
| Hardening | Wrote remediation scripts (least privilege, JIT, AES, honeytoken) | Reviewed; to be applied and verified in Phase 4 |
| Risk assessment & IR playbook | Drafted the executive report (NIST CSF 2.0 / 800-53) and the IR playbook | Reviewed for accuracy |
| Documentation | Drafted READMEs, the getting-started guide, and this file | Directed structure/audience; reviewed and corrected |
| Validation & results | Explained how to test each stage | **All of it** - built, ran, verified, and captured every result myself |

## What the AI got wrong, and I caught and fixed

This is the part I'm proudest of, because catching and fixing generated code is
the actual skill. Every item below is something that failed when I ran it and that
I diagnosed and corrected. The fixes are reflected in the committed code.

1. **PowerShell type bug in AD setup** (`02-configure-ad.ps1`). `New-ADUser`'s
   `-PasswordNeverExpires` was passed a `[switch]` instead of a `[bool]`, which
   fails with "Cannot convert SwitchParameter to Nullable[Boolean]". It only
   surfaced at provision time. Fixed by casting `([bool]$NeverExpires)`.

2. **Kerberoast blocked by modern AD defaults.** The seed account allowed only AES,
   so the roast failed with `KDC_ERR_ETYPE_NOSUPP`. Modern Windows Server is
   AES-only by default. Fixed the seed script to set
   `msDS-SupportedEncryptionTypes=4` (RC4) - the realistic legacy misconfiguration
   that makes an account roastable with a crackable ticket.

3. **BloodHound didn't collect local admins.** `bloodhound-python` returned no
   `AdminTo` edge for the service account. I confirmed the admin rights directly
   with `Get-LocalGroupMember` (stronger evidence than the graph), and documented
   the collector limitation rather than chasing it.

4. **Defender quarantined SharpHound.** `SharpHound.exe` vanished from the shared
   folder - Windows Defender ate it (expected for a known offensive tool). Worked
   around it with an AV exclusion; it also illustrates exactly why offensive tools
   trip defenses, which is the theme of this project.

5. **hashcat needed a GPU.** No OpenCL/CUDA in the VM, so hashcat wouldn't run even
   with `--force`. Pivoted to John the Ripper (CPU-only) and cracked the hash with a
   targeted season+year wordlist - a realistic technique when you know an org's
   password habits.

6. **Network path blocked by Windows Firewall.** The attacker could not reach the
   DC/file server over SMB. Diagnosed by comparing inter-VM reachability
   (fs01 -> dc01 worked, Kali -> dc01 didn't) and VirtualBox adapter attachments.
   Fixed with a scoped lab-subnet allow rule, now baked into provisioning
   (`configure-firewall.ps1`).

7. **Kali's lab adapter didn't initialize on first boot.** `eth1` had no address;
   `vagrant reload kali` brought it up attached to the internal network. Noted in
   the Vagrantfile.

8. **SIEM disk filled and the manager wouldn't start** ("No space left on
   device"). The 31 GB disk was 100% full. Traced it with `du` to Wazuh's
   Vulnerability Detection updater (`/var/ossec/queue/vd_updater`, ~16 GB of CVE
   feed). Cleared it, and disabled the unused module (now done automatically in the
   install script). Real SIEM resource management.

9. **Detection rules didn't fire - two separate bugs.**
   - The Kerberoast 4769 event reported `ticketEncryptionType = 0xffffffff`, not
     the textbook `0x17`, so the rule never matched. Caught it by inspecting the
     real event in Wazuh; fixed the rule to match both.
   - The rules chained off `<if_group>windows>` / `windows_security`, which didn't
     match how these events were tagged. Switched to `<decoded_as>json</decoded_as>`
     and validated with `wazuh-logtest` until rule 100100 fired at level 12 with
     the correct MITRE T1558.003 mapping.

The lesson across all nine: never trust generated (or documented) values until you
run them in your own environment. Every rule here was validated against a real
event before I believed it.

## Why document this

Being upfront about AI assistance is more honest than hiding it, and in security
the ability to critically review generated code and verify it actually works is
itself a core skill. This project reflects both: AI-accelerated authoring, and my
own hands-on validation, troubleshooting, and judgment.
