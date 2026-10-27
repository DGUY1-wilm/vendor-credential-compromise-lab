# Threat hunts

Hypothesis-driven hunts against the lab telemetry. Each starts from a question a
defender would ask about third-party access, not from an alert. The flow is:
hypothesis -> data -> query -> findings -> **new detection**. A hunt that finds
something becomes a Sigma rule in `../detections/`; a hunt that finds nothing
still documents coverage.

Run these in the Wazuh dashboard (Discover / the indexer search). Field names
follow Wazuh's decoded schema (`data.win.system.eventID`,
`data.win.eventdata.*`); adjust if your version differs.

| # | Hunt | Hypothesis in one line |
|---|------|------------------------|
| 1 | `hunt-01-vendor-scope.md` | A vendor account is reaching hosts/data outside its contract |
| 2 | `hunt-02-service-account-abuse.md` | A service account is being used like a user |
| 3 | `hunt-03-kerberoasting.md` | Someone is harvesting service-ticket hashes to crack offline |
