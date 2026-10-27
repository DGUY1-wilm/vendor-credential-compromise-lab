# Enables the Windows audit subcategories the detections rely on.
# Verify afterwards with: auditpol /get /category:*
$ErrorActionPreference = 'Stop'

$Subcategories = @(
    'Credential Validation', 'Kerberos Authentication Service', 'Kerberos Service Ticket Operations',
    'Logon', 'Logoff', 'Special Logon', 'Account Lockout',
    'User Account Management', 'Security Group Management',
    'File Share', 'Process Creation'
)
foreach ($s in $Subcategories) {
    auditpol /set /subcategory:"$s" /success:enable /failure:enable | Out-Null
}

# Include full command lines in process-creation events (4688)
New-Item -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' -Force | Out-Null
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System\Audit' `
    -Name ProcessCreationIncludeCmdLine_Enabled -Value 1 -Type DWord

Write-Host "[$env:COMPUTERNAME] Audit policy applied."
