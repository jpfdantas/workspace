#!/usr/bin/env bash
# Uso: .smolvm/delete.sh — para (se necessario) e deleta a VM.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
smolvm machine stop --name "${NAME}" 2>/dev/null || true
smolvm machine delete --name "${NAME}"
