# Ambiente isolado unificado (smolvm, Lima, DevPod)

Base unica: `.devcontainer/Containerfile` + `.smolvm/setup.sh` (idempotente). Sem diretorio `infra/`: tudo em `.smolvm/`, `.lima/` e `.devcontainer/`. Nenhum runtime monta credenciais do host; segredos entram via ambiente em runtime. Rode tudo na **raiz do repositorio**.

## smolvm
```bash
podman build -t localhost/dev-sandbox:latest -f .devcontainer/Containerfile .
export API_KEY=...   # opcional; permanece no host
podman save localhost/dev-sandbox:latest | smolvm machine create --name dev -s .smolvm/Smolfile --image -
smolvm machine start --name dev
smolvm machine exec --name dev -- bash
```

## Lima
```bash
limactl start --name=dev ./.lima/template.yaml
limactl shell dev
```
O mount `{{.Dir}}/..` aponta para a raiz do repo (relativo ao template). Provision roda `/workspace/.smolvm/setup.sh` como usuario.

## DevPod
```bash
devpod provider add docker      # ou: podman / lima
devpod provider use docker
devpod up . --ide none
devpod ssh <nome-do-workspace>
```
`devcontainer.json` usa `remoteUser: dev`, sem mounts de credenciais.

## Validacao
```bash
python3 -c "import json;json.load(open('.devcontainer/devcontainer.json'))"
python3 -c "import yaml;yaml.safe_load(open('.lima/template.yaml'))"
bash -n .smolvm/setup.sh && shellcheck .smolvm/setup.sh
```
