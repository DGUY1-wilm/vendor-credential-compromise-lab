# Detections

Detections for the Phase 2 attack chain, in two forms:

- **`sigma/`** — vendor-neutral [Sigma](https://github.com/SigmaHQ/sigma) rules.
  The portable, portfolio-facing artifact; convert to any SIEM with `sigma`/`sigmac`.
- **`wazuh/local_rules.xml`** — working translations for this lab's Wazuh SIEM.

Each Sigma rule names the Phase 2 step it catches and its ATT&CK technique.

## Coverage map

| Attack step | Sigma rule | Wazuh ID |
|-------------|-----------|----------|
| Recon / over-exposed share | sensitive_share_access_by_vendor_or_service | 100104 |
| Vendor cred used off-scope | vendor_account_out_of_scope_logon | 100101 |
| BloodHound (honey bait) | honeytoken_account_used | 100107 |
| Kerberoast | kerberoasting_rc4_tgs_request | 100100 |
| Lateral move (svc acct) | service_account_admin_logon | 100102 |
| secretsdump | impacket_secretsdump_service | 100103 |
| Collection / staging | sensitive_share_access_by_vendor_or_service | 100104 |
| Persistence (task) | scheduled_task_created_on_server | 100106 |
| Persistence (account) | rogue_local_admin_account | 100105 |

## Deploy to Wazuh (siem01)

```bash
sudo nano /var/ossec/etc/rules/local_rules.xml     # paste the rules from wazuh/
sudo systemctl restart wazuh-manager
```

## Test a rule without running the whole attack

`wazuh-logtest` lets you paste a sample event and see which rule fires:

```bash
sudo /var/ossec/bin/wazuh-logtest
```

Verify decoded field names match (`win.eventdata.ticketEncryptionType`, etc.) —
these vary by Wazuh version and are the most common reason a rule silently
doesn't fire. Adjust the XML to match what `wazuh-logtest` shows for a real event.

## Tuning note
The rules are intentionally tight to the lab (naming conventions `v-*`, `svc-*`,
hosts `fs01`/`dc01`). In a real estate you'd drive these from asset/identity
inventory rather than name prefixes. That trade-off is worth stating in your
write-up — it shows you know the difference between a lab rule and a production one.
