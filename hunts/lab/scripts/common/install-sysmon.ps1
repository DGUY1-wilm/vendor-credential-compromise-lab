# Installs Sysmon with the SwiftOnSecurity baseline config.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Pin to a specific commit hash instead of 'master' for reproducible builds
$SysmonConfigRef = 'master'

if (Get-Service Sysmon64 -ErrorAction SilentlyContinue) {
    Write-Host "[$env:COMPUTERNAME] Sysmon already installed, skipping."
    exit 0
}

$dir = 'C:\Tools\Sysmon'
New-Item -ItemType Directory -Force -Path $dir | Out-Null
Invoke-WebRequest 'https://download.sysinternals.com/files/Sysmon.zip' -OutFile "$dir\Sysmon.zip" -UseBasicParsing
Expand-Archive "$dir\Sysmon.zip" -DestinationPath $dir -Force
Invoke-WebRequest "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/$SysmonConfigRef/sysmonconfig-export.xml" `
    -OutFile "$dir\sysmonconfig.xml" -UseBasicParsing

& "$dir\Sysmon64.exe" -accepteula -i "$dir\sysmonconfig.xml"
Write-Host "[$env:COMPUTERNAME] Sysmon installed."
