#!/usr/bin/env bash
# Escreve, DENTRO da VM, o arquivo de token sintetico (fallback em arquivo do agy, sem keyring).
set -euo pipefail
NAME="${AGY_VM_NAME:-agy}"
smolvm machine exec --name "${NAME}" -- bash -c '
set -euo pipefail
case "${AGY_ACCESS_TOKEN:-}" in "") echo "erro: AGY_ACCESS_TOKEN ausente na VM" >&2; exit 1;; esac
tok="${AGY_ACCESS_TOKEN#Bearer }"
f="$HOME/.gemini/antigravity-cli/antigravity-oauth-token"
umask 077
mkdir -p "$(dirname "$f")"
jq -n --arg t "$tok" "{token:{access_token:\$t,token_type:\"Bearer\",refresh_token:\"fake-refresh\",expiry:\"2099-01-01T00:00:00Z\",expires_in:3599},auth_method:\"consumer\",id_token_email:\"sandbox@example.com\",writer_id:\"\"}" > "$f"
echo "token sintetico escrito em $f"
'
