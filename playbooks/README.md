# Incident response

- `ir-compromised-third-party-credential.md` — playbook for a suspected stolen or
  misused vendor/third-party credential, following the SANS/NIST SP 800-61
  lifecycle (prepare, detect & analyse, contain, eradicate, recover, post-incident).

Each phase ties to the detections in `../detections/` and the controls in
`../harden/`, so the playbook reflects what this project can actually detect and
contain, not a generic template.
