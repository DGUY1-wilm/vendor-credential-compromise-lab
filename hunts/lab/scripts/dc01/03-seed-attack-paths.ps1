# Run on dc01 from an elevated PowerShell:  C:\vagrant\scripts\dc01\03-seed-attack-paths.ps1
# Adds a Kerberoastable service account that is also a local admin on fs01 (set by
# the fs01 seed script). This creates the chain: v-coolair -> Kerberoast svc-backup
# -> admin on fs01. Weaknesses [W8][W9], documented in docs/baseline-weaknesses.md.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

$DomainDN = (Get-ADDomain).DistinguishedName

if (-not (Get-ADOrganizationalUnit -Filter "Name -eq 'ServiceAccounts'" -SearchBase $DomainDN -SearchScope OneLevel)) {
    New-ADOrganizationalUnit -Name 'ServiceAccounts' -Path $DomainDN -ProtectedFromAccidentalDeletion $false
}

# [W8] Service account with an SPN and a guessable season+year password that never
# expires. The SPN makes it Kerberoastable by ANY authenticated user (incl. v-coolair).
if (-not (Get-ADUser -Filter "SamAccountName -eq 'svc-backup'")) {
    New-ADUser -SamAccountName 'svc-backup' -UserPrincipalName 'svc-backup@acme.lab' `
        -Name 'svc-backup (Backup Service)' -Path "OU=ServiceAccounts,$DomainDN" `
        -Description 'SQL backup service account' `
        -AccountPassword (ConvertTo-SecureString 'Autumn2024!' -AsPlainText -Force) `
        -Enabled $true -PasswordNeverExpires $true
}
# Register an SPN -> this is what makes the account roastable
Set-ADUser -Identity 'svc-backup' -ServicePrincipalNames @{Replace='MSSQLSvc/fs01.acme.lab:1433'}

Write-Host '[dc01] svc-backup seeded (Kerberoastable). Now run the fs01 seed script.'
