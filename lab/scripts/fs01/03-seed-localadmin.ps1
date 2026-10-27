# Run on fs01 from an elevated PowerShell:  C:\vagrant\scripts\fs01\03-seed-localadmin.ps1
# [W9] Makes the service account a local administrator on fs01 - more rights than a
# backup job needs, and the pivot the attacker uses after cracking its password.
$ErrorActionPreference = 'Stop'
try {
    Add-LocalGroupMember -Group 'Administrators' -Member 'ACME\svc-backup' -ErrorAction Stop
    Write-Host '[fs01] ACME\svc-backup added to local Administrators.'
} catch [Microsoft.PowerShell.Commands.MemberExistsException] {
    Write-Host '[fs01] svc-backup already a local admin, skipping.'
}
