#!/usr/bin/env bash
# Bootstrap idempotente do ambiente (build da imagem e pos-provisionamento Lima).
set -euo pipefail

WORKSPACE="${WORKSPACE:-/workspace}"
PROFILE_D="${HOME}/.config/dev-env.sh"
MARK_BEGIN="# >>> dev-env >>>"

# Diretorios XDG
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-${HOME}/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-${HOME}/.local/state}"
mkdir -p "${XDG_CONFIG_HOME}" "${XDG_DATA_HOME}" "${XDG_CACHE_HOME}" "${XDG_STATE_HOME}" "${HOME}/.local/bin"

# Variaveis de ambiente padrao (sobrescritas a cada execucao)
cat > "${PROFILE_D}" <<ENVEOF
export XDG_CONFIG_HOME="\${XDG_CONFIG_HOME:-\$HOME/.config}"
export XDG_DATA_HOME="\${XDG_DATA_HOME:-\$HOME/.local/share}"
export XDG_CACHE_HOME="\${XDG_CACHE_HOME:-\$HOME/.cache}"
export XDG_STATE_HOME="\${XDG_STATE_HOME:-\$HOME/.local/state}"
export PATH="\$HOME/.local/bin:\$PATH"
export TZ="\${TZ:-UTC}"
export EDITOR="\${EDITOR:-vi}"
ENVEOF

# Carrega no shell apenas uma vez
if ! grep -qF "${MARK_BEGIN}" "${HOME}/.bashrc" 2>/dev/null; then
  {
    echo "${MARK_BEGIN}"
    echo '[ -f "$HOME/.config/dev-env.sh" ] && . "$HOME/.config/dev-env.sh"'
    echo "# <<< dev-env <<<"
  } >> "${HOME}/.bashrc"
fi

# Git: defaults seguros, sem credenciais
git config --global init.defaultBranch main
git config --global --add safe.directory "${WORKSPACE}" 2>/dev/null || true

# Permissoes do workspace (best effort: pode ser mount somente leitura/virtiofs)
if [ -d "${WORKSPACE}" ] && [ -w "${WORKSPACE}" ]; then
  :
elif [ -d "${WORKSPACE}" ]; then
  echo "aviso: ${WORKSPACE} nao e gravavel por $(id -un)" >&2
fi

echo "setup.sh: ok"
