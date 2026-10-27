# Run on dc01 (elevated). Deploys a decoy "honeytoken" account and a canary file.
# The account looks like a juicy privileged service account but is never used, so
# any authentication attempt (caught by Sigma honeytoken_account_used /
# Wazuh rule 100107) is high-confidence malicious.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory
$DomainDN = (Get-ADDomain).DistinguishedName

if (-not (Get-ADUser -Filter "SamAccountName -eq 'svc-sql-admin'")) {
    Add-Type -AssemblyName System.Web
    $pw = [System.Web.Security.Membership]::GeneratePassword(30, 8)
    New-ADUser -SamAccountName 'svc-sql-admin' -UserPrincipalName 'svc-sql-admin@acme.lab' `
        -Name 'svc-sql-admin (SQL Admin Service)' -Path "OU=ServiceAccounts,$DomainDN" `
        -Description 'SQL Server admin service account - DO NOT DISABLE' `
        -AccountPassword (ConvertTo-SecureString $pw -AsPlainText -Force) -Enabled $true
    # A dangling SPN makes it show up as Kerberoastable in BloodHound = irresistible bait
    Set-ADUser svc-sql-admin -ServicePrincipalNames @{Replace='MSSQLSvc/sql01.acme.lab:1433'}
    Write-Host '[Honeytoken] Created decoy account svc-sql-admin (looks roastable, never used).'
} else {
    Write-Host '[Honeytoken] svc-sql-admin already exists.'
}
Write-Host '[+] Any auth for svc-sql-admin should now fire Wazuh rule 100107 (critical).'
