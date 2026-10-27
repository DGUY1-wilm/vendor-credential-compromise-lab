# Hunt 01 — Vendor account operating outside its scope

**Hypothesis:** If a vendor credential has been stolen, the account will
authenticate to hosts, or read data, that its legitimate job never requires.
CoolAir HVAC's `v-coolair` should only ever touch the Facilities material on
fs01.

**ATT&CK:** T1078.002 (Valid Accounts: Domain), T1199 (Trusted Relationship)

**Data sources:** Windows Security 4624/4625 (logons), 5145 (detailed share
access), from dc01 and fs01 via Wazuh.

## Questions and queries

1. **Every host v-coolair has authenticated to:**
   ```
   data.win.eventdata.targetUserName:"v-coolair" AND data.win.system.eventID:"4624"
   ```
   Pivot on `data.win.system.computer`. Anything other than fs01 is out of scope.

2. **Every share path v-coolair (or any v-*) has opened:**
   ```
   data.win.eventdata.subjectUserName:v-* AND data.win.system.eventID:"5145"
   ```
   Pivot on `data.win.eventdata.shareName`. Finance or HR here is a finding.

3. **Failed logons for vendor accounts** (spray / reuse attempts):
   ```
   data.win.eventdata.targetUserName:v-* AND data.win.system.eventID:"4625"
   ```

## Expected finding (post Phase 2)
v-coolair authenticating to dc01 and reading the Finance share — neither in scope.

## Detection produced
`detections/sigma/vendor_account_out_of_scope_logon.yml` and
`sensitive_share_access_by_vendor_or_service.yml` (Wazuh 100101 / 100104).

## Notes / what I actually found
_(fill in)_
