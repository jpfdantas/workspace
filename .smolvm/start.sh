#!/usr/bin/env bash
# Uso: .smolvm/start.sh — builda a imagem, cria/inicia a VM e entra nela.
# Se a VM ja existe: inicia (se parada) ou renova a credencial (se rodando).
# Para aplicar uma imagem nova: .smolvm/delete.sh e depois .smolvm/start.sh.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "${ROOT}"  # o mount ".:/workspace" do Smolfile e relativo ao cwd

podman build -t "${IMAGE}" -f .devcontainer/Containerfile .
load_host_token

line="$(vm_line)"
if [ -z "${line}" ]; then
  podman save "${IMAGE}" | smolvm machine create --name "${NAME}" -s "${DIR}/Smolfile" --image -
fi
if [[ "${line}" == *running* ]]; then
  smolvm machine credentials refresh --name "${NAME}"
else
  smolvm machine start --name "${NAME}"
  "${DIR}/guest-creds.sh"
fi
exec smolvm machine exec -it --name "${NAME}" -- bash
