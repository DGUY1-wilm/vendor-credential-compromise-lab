# Installs the Wazuh agent, enrolls it with siem01, and adds Sysmon log collection.
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$WazuhVersion = '4.9.2-1'      # Must be <= the manager version on siem01
$Manager      = '10.10.10.20'
$Conf         = 'C:\Program Files (x86)\ossec-agent\ossec.conf'

if (-not (Get-Service WazuhSvc -ErrorAction SilentlyContinue)) {
    $msi = Join-Path $env:TEMP 'wazuh-agent.msi'
    Invoke-WebRequest "https://packages.wazuh.com/4.x/windows/wazuh-agent-$WazuhVersion.msi" -OutFile $msi -UseBasicParsing
    Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /q WAZUH_MANAGER=$Manager" -Wait
}

# Wazuh accepts multiple <ossec_config> blocks, so append rather than edit in place
if (-not (Select-String -Path $Conf -Pattern 'Sysmon/Operational' -Quiet)) {
    Add-Content -Path $Conf -Value @'

<ossec_config>
  <localfile>
    <location>Microsoft-Windows-Sysmon/Operational</location>
    <log_format>eventchannel</log_format>
  </localfile>
</ossec_config>
'@
}

Restart-Service WazuhSvc
Write-Host "[$env:COMPUTERNAME] Wazuh agent running, reporting to $Manager."
