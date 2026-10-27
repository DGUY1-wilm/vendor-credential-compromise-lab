# AI Usage & Transparency

This project was built with AI assistance (Anthropic's Claude), and I'm
documenting that openly. I believe how you use a tool matters more than whether
you use one — so this file records what the AI produced versus what I did myself.

**My role in one line:** I designed the project, made the decisions, ran and
validated everything in a real environment, troubleshot what broke, and supplied
the genuine findings. The AI accelerated the writing of code and documentation; it
did not run the lab or produce the results — I did.

Understanding every file well enough to explain it in an interview was a
requirement, not an afterthought. Where the AI was wrong or made lab-specific
assumptions, I corrected them against what actually happened on my machine.

## Task-by-task breakdown

| Task | What the AI did | What I did |
|------|-----------------|------------|
| Project scope & threat model | Suggested framing around T1078 / T1199 and the Target / Snowflake precedents | Chose the topic, defined the goal, decided it should be one flagship project with multiple deliverables |
| Lab design | Wrote the Vagrantfile and provisioning scripts (AD, file server, SIEM) | Specified the environment (host specs, Windows/Wazuh stack), reviewed the design, decided the topology |
| Building the lab | Provided commands and expected output | Installed VirtualBox/Vagrant, ran every build, hit and fixed real issues (PATH, reboots, timing), verified each VM came up |
| Attack chain (Phase 2) | Wrote the attack scripts and manual runbook; mapped steps to ATT&CK | Chose the approach (scripts + runbook, thorough tooling), will run the attack and record what actually happens |
| Detections (Phase 3) | Authored 8 Sigma rules and their Wazuh translations | Will deploy them, verify each fires with `wazuh-logtest`, and fix field-name mismatches for my Wazuh version |
| Threat hunts | Drafted 3 hypothesis-driven hunts with queries | Will run the hunts and fill in the real findings |
| Hardening | Wrote remediation scripts (least privilege, JIT, AES, honeytoken) | Will apply them and confirm each control actually took effect |
| Risk assessment | Drafted the executive report mapped to NIST CSF 2.0 / 800-53 | Reviewed for accuracy, will update the attack narrative with my real results |
| IR playbook | Drafted the response procedure tied to the project's detections | Reviewed the containment steps for soundness |
| Documentation | Drafted READMEs, this file, and the getting-started guide | Directed structure and audience, reviewed and edited for accuracy |
| Validation & results | Explained how to test each stage | **All of it** — running the lab, confirming it works, capturing evidence, recording findings |

## What the AI got wrong (and I caught)

_Running list — I'll add to this as I validate the lab, because knowing the
failure points is part of understanding the project._

- (e.g. Wazuh decoded field names needing adjustment for my version — to confirm)
- (e.g. tool version / install specifics that had changed — to confirm)

## Why document this

Being upfront about AI assistance is more honest than hiding it, and in security
the ability to critically review generated code and verify it actually works is
itself a core skill. This project reflects both: AI-accelerated authoring, and my
own hands-on validation, troubleshooting, and judgment.
