# Run on dc01 (elevated). Fixes the identity/privilege weaknesses W3, W6, W8.
# Pair with 02 (fs01) and 03 (honeytoken). See harden/README.md.
$ErrorActionPreference = 'Stop'
Import-Module ActiveDirectory

# --- [W3] Least privilege: vendor doesn't need Facilities group membership ---
# It already gets read on the Facilities share via Vendor-Access.
if (Get-ADGroupMember Facilities | Where-Object SamAccountName -eq 'v-coolair') {
    Remove-ADGroupMember -Identity Facilities -Members v-coolair -Confirm:$false
    Write-Host '[W3] Removed v-coolair from Facilities.'
}

# --- [W8] Kill the Kerberoast: rotate svc-backup to a long random password ---
# and deny RC4 for it. Production answer is a gMSA (see README); this is the
# in-lab equivalent that makes any roasted ticket uncrackable.
Add-Type -AssemblyName System.Web
$newPw = [System.Web.Security.Membership]::GeneratePassword(28, 6)
Set-ADAccountPassword -Identity svc-backup -Reset `
    -NewPassword (ConvertTo-SecureString $newPw -AsPlainText -Force)
# msDS-SupportedEncryptionTypes = 24 -> AES128+AES256 only, no RC4
Set-ADUser -Identity svc-backup -Replace @{'msDS-SupportedEncryptionTypes'=24}
Write-Host "[W8] Rotated svc-backup to a 28-char password and disabled RC4 for it."
Write-Host "     New password stored nowhere on purpose; for the lab, reset again if needed."

# --- [W6] Just-in-time access: vendor account disabled by default ------------
Disable-ADAccount -Identity v-coolair
Write-Host '[W6] Disabled v-coolair. Enable only for approved windows with Enable-VendorAccess.ps1.'

# --- Defense in depth: disable RC4 domain-wide for Kerberos (optional) -------
# Uncomment to enforce AES everywhere. Test first - legacy clients may break.
# Set-ADDomain -Identity acme.lab -Replace @{'msDS-SupportedEncryptionTypes'=24}

Write-Host '[+] Identity remediation complete.'
