#!/usr/bin/env bash
# Uso: .smolvm/stop.sh — para a VM.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
smolvm machine stop --name "${NAME}"
