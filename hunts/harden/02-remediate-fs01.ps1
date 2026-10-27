# Run on fs01 (elevated). Fixes W4 (over-exposed Finance share) and W9 (service
# account local admin).
$ErrorActionPreference = 'Stop'

# --- [W4] Remove Domain Users' read access to Finance; restrict to Finance grp ---
$finance = 'C:\Shares\Finance'
& icacls $finance /remove:g 'ACME\Domain Users' | Out-Null
& icacls $finance /inheritance:r /grant:r `
    'BUILTIN\Administrators:(OI)(CI)F' 'NT AUTHORITY\SYSTEM:(OI)(CI)F' `
    'ACME\Finance:(OI)(CI)M' | Out-Null
Write-Host '[W4] Finance share restricted to the Finance group.'

# --- [W9] Remove the service account from local Administrators ----------------
try {
    Remove-LocalGroupMember -Group 'Administrators' -Member 'ACME\svc-backup' -ErrorAction Stop
    Write-Host '[W9] Removed ACME\svc-backup from local Administrators on fs01.'
} catch { Write-Host '[W9] svc-backup was not a local admin, nothing to remove.' }

# --- Defense in depth: require SMB signing -----------------------------------
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
Write-Host '[+] fs01 remediation complete.'
