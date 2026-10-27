# JIT access: enable the vendor account for a bounded window, then auto-disable.
# Usage (on dc01, elevated):  .\Enable-VendorAccess.ps1 -Minutes 60
param([int]$Minutes = 60)
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

Enable-ADAccount -Identity v-coolair
$until = (Get-Date).AddMinutes($Minutes)
Write-Host "[JIT] v-coolair enabled until $until ($Minutes min). Logging to Application log."
Write-EventLog -LogName Application -Source 'Application' -EventId 9001 -EntryType Information `
    -Message "JIT vendor access granted for v-coolair until $until" -ErrorAction SilentlyContinue

# Simple auto-expiry. In production this would be a scheduled task or a PAM tool.
Start-Job { param($u) Start-Sleep -Seconds ($using:Minutes * 60); Import-Module ActiveDirectory; Disable-ADAccount v-coolair } -ArgumentList 'v-coolair' | Out-Null
Write-Host '[JIT] Auto-disable job scheduled.'
