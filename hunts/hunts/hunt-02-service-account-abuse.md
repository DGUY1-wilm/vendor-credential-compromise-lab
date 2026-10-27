# Hunt 02 — Service account used like a human

**Hypothesis:** A service account that normally only runs a background service
will, if compromised, start logging on interactively, moving between hosts, and
exercising admin rights.

**ATT&CK:** T1078.002, T1021 (Remote Services), T1003 (Credential Dumping)

**Data sources:** 4624 (logon type), 4672 (special privileges), 7045 (service
install), 4688 (process creation).

## Questions and queries

1. **Admin-level logons by svc-* accounts:**
   ```
   data.win.eventdata.subjectUserName:svc-* AND data.win.system.eventID:"4672"
   ```

2. **Interactive / remote-interactive logons by service accounts:**
   ```
   data.win.eventdata.targetUserName:svc-* AND data.win.system.eventID:"4624"
   AND data.win.eventdata.logonType:("2" OR "10")
   ```

3. **Transient services (secretsdump/psexec fingerprint):**
   ```
   data.win.system.eventID:"7045" AND data.win.eventdata.imagePath:(*cmd.exe* OR *powershell* OR *pipe*)
   ```

4. **Baseline first:** list the hosts each service account *normally* logs into,
   so "normal" is defined before you judge "abnormal".

## Expected finding (post Phase 2)
svc-backup logging into fs01 with 4672, plus a 7045 from secretsdump.

## Detection produced
`service_account_admin_logon.yml`, `impacket_secretsdump_service.yml`
(Wazuh 100102 / 100103).

## Notes / what I actually found
_(fill in)_
