# Allows inbound traffic from the isolated lab subnet so the SIEM, domain members,
# and (later) the attacker can reach each other. Windows Server blocks inbound SMB
# and other services from "unknown" networks by default, which otherwise breaks
# agent enrollment and the attack path. Scoped to 10.10.10.0/24 only - this is the
# flat internal network the baseline scenario assumes; it is never internet-facing.
$ErrorActionPreference = 'Stop'

if (-not (Get-NetFirewallRule -DisplayName 'Lab-Allow-Internal' -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName 'Lab-Allow-Internal' -Direction Inbound `
        -RemoteAddress 10.10.10.0/24 -Action Allow -Profile Any | Out-Null
    Write-Host "[$env:COMPUTERNAME] Firewall rule 'Lab-Allow-Internal' added (10.10.10.0/24)."
} else {
    Write-Host "[$env:COMPUTERNAME] Firewall rule 'Lab-Allow-Internal' already present."
}
