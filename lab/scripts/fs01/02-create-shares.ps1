# Creates department shares with FAKE data. [W4] Finance is readable by all Domain Users.
$ErrorActionPreference = 'Stop'
$Root = 'C:\Shares'

$Shares = @(
    @{ Name = 'Facilities'; Grants = @('ACME\Facilities:(OI)(CI)M', 'ACME\Vendor-Access:(OI)(CI)RX') },
    @{ Name = 'Finance';    Grants = @('ACME\Finance:(OI)(CI)M',    'ACME\Domain Users:(OI)(CI)RX') },  # [W4]
    @{ Name = 'HR';         Grants = @('ACME\HR:(OI)(CI)M') }
)

foreach ($s in $Shares) {
    $path = Join-Path $Root $s.Name
    New-Item -ItemType Directory -Force -Path $path | Out-Null
    # Replace inherited ACLs with explicit ones; NTFS does the access control
    $icaclsArgs = @($path, '/inheritance:r', '/grant:r',
              'BUILTIN\Administrators:(OI)(CI)F', 'NT AUTHORITY\SYSTEM:(OI)(CI)F') + $s.Grants
    & icacls @icaclsArgs | Out-Null
    if (-not (Get-SmbShare -Name $s.Name -ErrorAction SilentlyContinue)) {
        New-SmbShare -Name $s.Name -Path $path -FullAccess 'Everyone' | Out-Null
    }
}

# --- Fake data (clearly labeled; no real PII) ------------------------------------
$banner = '# FAKE LAB DATA - Acme Widgets (fictional company)'

$rows = 1..50 | ForEach-Object {
    [pscustomobject]@{
        InvoiceId = 'INV-{0:D5}' -f (10000 + $_)
        Vendor    = Get-Random -InputObject 'CoolAir HVAC','Bright Office Supply','Northwind Freight','Contoso Cleaning'
        AmountUSD = Get-Random -Minimum 500 -Maximum 75000
        BankAcct  = 'FAKE-{0:D8}' -f (Get-Random -Maximum 99999999)
    }
}
Set-Content "$Root\Finance\vendor_payments_2026.csv" $banner
$rows | ConvertTo-Csv -NoTypeInformation | Add-Content "$Root\Finance\vendor_payments_2026.csv"

$salaries = 1..40 | ForEach-Object {
    [pscustomobject]@{ EmployeeId = 'E{0:D4}' -f $_; Department = Get-Random -InputObject 'Finance','HR','Facilities','IT','Sales'; SalaryUSD = Get-Random -Minimum 45000 -Maximum 180000 }
}
Set-Content "$Root\HR\employee_salaries.csv" $banner
$salaries | ConvertTo-Csv -NoTypeInformation | Add-Content "$Root\HR\employee_salaries.csv"

Set-Content "$Root\Facilities\hvac_maintenance_schedule.txt" @"
$banner
Building A rooftop units RTU-1..RTU-4 - quarterly service by CoolAir HVAC
Remote monitoring account: v-coolair (managed by vendor)
"@

Write-Host '[fs01] Shares and fake data created.'
