#!/usr/bin/env bash
# Uso (na raiz do repo): .smolvm/host-token.sh create|refresh
# Le o access_token do keyring do host (renovado ao rodar `agy` no host) e entrega ao smolvm via ambiente.
# Nunca imprime nem grava o token.
set -euo pipefail

NAME="${AGY_VM_NAME:-agy}"
IMAGE="${AGY_IMAGE:-localhost/dev-sandbox:latest}"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# O agy guarda o OAuth no keyring (Secret Service): service=gemini, username=antigravity.
secret="$(secret-tool lookup service gemini username antigravity)" \
  || { echo "erro: item do keyring nao encontrado; rode o agy no host (login)" >&2; exit 1; }
expiry="$(jq -r '.token.expiry' <<<"${secret}")"
if [ "$(date -d "${expiry}" +%s)" -le "$(date +%s)" ]; then
  echo "erro: token expirado (${expiry}); rode o agy no host para renova-lo e tente de novo" >&2
  exit 1
fi
AGY_ACCESS_TOKEN="Bearer $(jq -r '.token.access_token' <<<"${secret}")"
unset secret
export AGY_ACCESS_TOKEN

case "${1:-}" in
  create)
    podman save "${IMAGE}" | smolvm machine create --name "${NAME}" -s "${DIR}/Smolfile" --image -
    smolvm machine start --name "${NAME}"
    "${DIR}/guest-creds.sh"
    ;;
  refresh)
    smolvm machine credentials refresh --name "${NAME}"
    ;;
  *) echo "uso: $0 create|refresh" >&2; exit 2 ;;
esac
