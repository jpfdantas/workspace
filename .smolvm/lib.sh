#!/usr/bin/env bash
# Funcoes compartilhadas (apenas `source`). Nunca imprime nem grava o token.
NAME="${AGY_VM_NAME:-agy}"
IMAGE="${AGY_IMAGE:-localhost/dev-sandbox:latest}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${DIR}/.." && pwd)"

# Linha da VM em `smolvm machine ls` (vazio se nao existe).
vm_line() { smolvm machine ls 2>/dev/null | grep -w -- "${NAME}" || true; }

# Le o access_token do keyring do host (renovado ao rodar `agy` no host) e exporta AGY_ACCESS_TOKEN.
load_host_token() {
  local secret expiry
  # O agy guarda o OAuth no keyring (Secret Service): service=gemini, username=antigravity.
  secret="$(secret-tool lookup service gemini username antigravity)" \
    || { echo "erro: item do keyring nao encontrado; rode o agy no host (login)" >&2; return 1; }
  expiry="$(jq -r '.token.expiry' <<<"${secret}")"
  if [ "$(date -d "${expiry}" +%s)" -le "$(date +%s)" ]; then
    echo "erro: token expirado (${expiry}); rode o agy no host para renova-lo e tente de novo" >&2
    return 1
  fi
  AGY_ACCESS_TOKEN="Bearer $(jq -r '.token.access_token' <<<"${secret}")"
  export AGY_ACCESS_TOKEN
}
