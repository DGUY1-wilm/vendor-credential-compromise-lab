# Installs AD DS and creates the acme.lab forest. Vagrant reboots afterwards.
$ErrorActionPreference = 'Stop'

$DomainName  = 'acme.lab'
$NetbiosName = 'ACME'
# Lab-only password. This lab must never be reachable from a real network.
$SafeModePw  = ConvertTo-SecureString 'Lab-DSRM-2026!' -AsPlainText -Force

# DomainRole 4/5 = domain controller; makes the script safe to re-run
if ((Get-CimInstance Win32_ComputerSystem).DomainRole -ge 4) {
    Write-Host '[dc01] Already a domain controller, skipping.'
    exit 0
}

Install-WindowsFeature AD-Domain-Services -IncludeManagementTools | Out-Null
Import-Module ADDSDeployment
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -SafeModeAdministratorPassword $SafeModePw `
    -InstallDns `
    -NoRebootOnCompletion `
    -Force | Out-Null

Write-Host "[dc01] Forest $DomainName created. Rebooting via vagrant-reload."
