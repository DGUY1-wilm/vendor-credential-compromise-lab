#!/usr/bin/env bash
# Installs the attack toolkit on the Kali box. Most ship with Kali already; this
# makes the VM reproducible from the repo. Versions move fast - if a package name
# has changed, `apt search` / `pipx list` and adjust.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
# nxc = NetExec (the maintained successor to CrackMapExec)
apt-get install -y -qq netexec impacket-scripts bloodhound.py evil-winrm hashcat smbclient ldap-utils 2>/dev/null || true

# Fallbacks via pipx if a repo package was renamed/missing
command -v nxc            >/dev/null || pipx install netexec
command -v bloodhound-python >/dev/null || pipx install bloodhound

# rockyou ships gzipped on Kali; unpack it for hashcat
if [ -f /usr/share/wordlists/rockyou.txt.gz ] && [ ! -f /usr/share/wordlists/rockyou.txt ]; then
    gunzip -k /usr/share/wordlists/rockyou.txt.gz
fi

echo '[kali] Attack toolkit ready. See /vagrant or the repo attack/ folder for scripts.'
