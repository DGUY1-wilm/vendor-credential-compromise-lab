#!/usr/bin/env bash
# Shared config for the attack chain. Source this from the other scripts.
#
# SCENARIO: The vendor credential below was harvested from CoolAir HVAC's
# workstation by an infostealer. We start POST-THEFT - this lab does not build
# or run any credential-stealing malware. Everything here is valid-account abuse
# (MITRE T1078) plus standard tooling, against an environment you own.

set -euo pipefail

# --- Targets (all inside the isolated lab subnet) ---------------------------
export DOMAIN="acme.lab"
export DC_IP="10.10.10.10"
export FS_IP="10.10.10.11"
export DC_HOST="dc01.acme.lab"
export FS_HOST="fs01.acme.lab"

# --- The "stolen" vendor credential ----------------------------------------
export VENDOR_USER="v-coolair"
export VENDOR_PASS="CoolAir2024!"

# --- Output ------------------------------------------------------------------
export LOOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/loot"
mkdir -p "$LOOT"

# --- SAFETY GUARD ------------------------------------------------------------
# Refuse to run against anything outside the lab. This is deliberate: the tools
# below are real, and this keeps them pointed only at 10.10.10.0/24.
assert_lab_target() {
    local ip="$1"
    case "$ip" in
        10.10.10.*) : ;;
        *) echo "REFUSING: '$ip' is outside the lab subnet 10.10.10.0/24." >&2
           echo "This toolkit only runs against the isolated acme.lab network." >&2
           exit 1 ;;
    esac
}

banner() { printf '\n========== %s ==========\n' "$1"; }
atk()    { printf '   [ATT&CK] %s\n' "$1"; }
expect() { printf '   [EXPECTED TELEMETRY] %s\n' "$1"; }
