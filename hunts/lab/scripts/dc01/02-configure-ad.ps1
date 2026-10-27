# Builds the Acme Widgets directory: OUs, groups, staff, and the HVAC vendor account.
# Intentional weaknesses are tagged [W#] and documented in docs/baseline-weaknesses.md.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

# Wait for AD Web Services after the post-promotion reboot
$tries = 0
while ($true) {
    try { Get-ADDomain | Out-Null; break }
    catch { $tries++; if ($tries -gt 30) { throw 'AD did not come up' }; Start-Sleep 10 }
}
$DomainDN = (Get-ADDomain).DistinguishedName

# Forward external lookups so domain members can still reach the internet for setup
foreach ($ip in '1.1.1.1', '8.8.8.8') {
    if (-not ((Get-DnsServerForwarder).IPAddress.IPAddressToString -contains $ip)) {
        Add-DnsServerForwarder -IPAddress $ip
    }
}

# --- OUs and groups ----------------------------------------------------------
foreach ($ou in 'Staff', 'Admins', 'Vendors', 'Servers', 'Groups') {
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'" -SearchBase $DomainDN -SearchScope OneLevel)) {
        New-ADOrganizationalUnit -Name $ou -Path $DomainDN -ProtectedFromAccidentalDeletion $false
    }
}
foreach ($g in 'Finance', 'Facilities', 'HR', 'Vendor-Access') {
    if (-not (Get-ADGroup -Filter "Name -eq '$g'")) {
        New-ADGroup -Name $g -GroupScope Global -GroupCategory Security -Path "OU=Groups,$DomainDN"
    }
}

function New-LabUser {
    param($Sam, $Given, $Surname, $OU, $Password, $Description, [string[]]$Groups, [switch]$NeverExpires)
    if (-not (Get-ADUser -Filter "SamAccountName -eq '$Sam'")) {
        New-ADUser -SamAccountName $Sam -UserPrincipalName "$Sam@acme.lab" `
            -Name "$Given $Surname" -GivenName $Given -Surname $Surname `
            -Description $Description -Path "OU=$OU,$DomainDN" `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled $true -PasswordNeverExpires:$NeverExpires
    }
    foreach ($g in $Groups) { Add-ADGroupMember -Identity $g -Members $Sam -ErrorAction SilentlyContinue }
}

# --- Staff (lab-only passwords) ---------------------------------------------------
New-LabUser jsmith   Jane  Smith  Staff  'Lab-Staff-2026!' 'Finance analyst'      -Groups Finance
New-LabUser mgarcia  Marco Garcia Staff  'Lab-Staff-2026!' 'Facilities manager'   -Groups Facilities
New-LabUser tnguyen  Tina  Nguyen Staff  'Lab-Staff-2026!' 'HR generalist'        -Groups HR
New-LabUser adm-rpatel Raj Patel  Admins 'Lab-Admin-2026!' 'IT admin account'     -Groups 'Domain Admins'

# --- Vendor account: the credential the attacker will "steal" --------------------
# [W2] Shared account for the whole vendor, password never expires
# [W3] Added to Facilities in addition to Vendor-Access (more than the job needs)
New-LabUser v-coolair CoolAir 'HVAC (vendor)' Vendors 'CoolAir2024!' `
    'CoolAir HVAC Services - shared remote monitoring account' `
    -Groups 'Vendor-Access', 'Facilities' -NeverExpires

Write-Host '[dc01] Directory configured.'
