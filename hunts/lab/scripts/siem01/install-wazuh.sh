#!/usr/bin/env bash
# Installs Wazuh all-in-one (indexer, manager, dashboard) on siem01.
# Generated passwords are copied to lab/.secrets/ (git-ignored).
set -euo pipefail

WAZUH_RELEASE="4.9"            # Keep the Windows agent version <= this release
SECRETS_DIR="/vagrant/.secrets"

if systemctl is-active --quiet wazuh-manager; then
  echo "[siem01] Wazuh already installed, skipping."
  exit 0
fi

cd /root
curl -sSfO "https://packages.wazuh.com/${WAZUH_RELEASE}/wazuh-install.sh"
# -a = all-in-one, -i = skip hardware checks (lab VM is below production spec)
bash ./wazuh-install.sh -a -i

mkdir -p "$SECRETS_DIR"
tar -O -xf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt \
  > "$SECRETS_DIR/wazuh-passwords.txt"

echo "[siem01] Wazuh dashboard: https://127.0.0.1:8443"
echo "[siem01] Login: admin / see lab/.secrets/wazuh-passwords.txt"
