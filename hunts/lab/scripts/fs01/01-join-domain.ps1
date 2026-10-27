# Points DNS at dc01 and joins fs01 to acme.lab. Vagrant reboots afterwards.
$ErrorActionPreference = 'Stop'
$DomainName = 'acme.lab'
$DcIp       = '10.10.10.10'

if ((Get-CimInstance Win32_ComputerSystem).PartOfDomain) {
    Write-Host '[fs01] Already domain-joined, skipping.'
    exit 0
}

# All adapters use the DC for DNS; the DC forwards external names
Get-NetAdapter | ForEach-Object {
    Set-DnsClientServerAddress -InterfaceIndex $_.ifIndex -ServerAddresses $DcIp
}

$tries = 0
while (-not (Resolve-DnsName $DomainName -ErrorAction SilentlyContinue)) {
    $tries++; if ($tries -gt 30) { throw "Cannot resolve $DomainName - is dc01 up?" }
    Start-Sleep 10
}

# After promotion, the box's local 'vagrant' admin became a domain admin on dc01
$cred = New-Object PSCredential('ACME\vagrant', (ConvertTo-SecureString 'vagrant' -AsPlainText -Force))
Add-Computer -DomainName $DomainName -Credential $cred -OUPath 'OU=Servers,DC=acme,DC=lab' -Force
Write-Host '[fs01] Joined acme.lab. Rebooting via vagrant-reload.'
