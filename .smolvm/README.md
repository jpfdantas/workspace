# Sandbox `smolvm` para o Antigravity CLI (`agy`)

Imagem Debian bookworm com Liberica NIK 25 (JDK + `native-image`), Gradle via wrapper do projeto, Podman, `kubectl`, `helm`, `kind`, `trivy`, `gitleaks`, `terraform`, Bruno CLI e o `agy`.
O `Smolfile` e a imagem **nao contem segredos nem caminhos pessoais**.

Rode todos os comandos **a partir da raiz do repositorio** (o mount `.:/workspace` e relativo ao diretorio atual).

## 1. Build da imagem
```bash
podman build -t localhost/agy-sandbox:latest -f .smolvm/Containerfile .smolvm
```
> Se o Podman reclamar de `registries.conf must be in v2 format`, converta seu
> `~/.config/containers/registries.conf` para `unqualified-search-registries = ["docker.io"]`.

## 2. Criar e subir a VM
O `smolvm` trata `localhost/agy-sandbox:latest` como referencia de registry, entao a imagem local entra via `podman save`:
```bash
export GEMINI_API_KEY=...   # fica no HOST; a VM so ve um placeholder

podman save localhost/agy-sandbox:latest | smolvm machine create --name agy \
  -s .smolvm/Smolfile --image -

smolvm machine start --name agy
```

## 3. Executar o `agy` headless
```bash
smolvm machine exec --name agy -- \
  agy --settings '{"modelProvider":"gemini"}' -p "sua tarefa"
```

## Credenciais (nada de segredo dentro da VM)
O `Smolfile` declara `[[network.credentials]]` para `GEMINI_API_KEY`: o guest recebe um
placeholder e o `smolvm` injeta a chave real, do ambiente do host, so em HTTPS para
`generativelanguage.googleapis.com` (header `x-goog-api-key`). Rotacionar sem reiniciar:
`smolvm machine credentials refresh --name agy`.

**Nao monte o seu `~/.gemini` real.** Se precisar de OAuth, faca login dentro da VM
(armazenamento em arquivo, descartavel com a VM) ou monte uma copia dedicada, somente leitura.

## Montagens pessoais (opcionais, via flags no `create`)
Nada de caminho do seu `/home` entra no `Smolfile`. Adicione no `machine create`:
```bash
  -v "$HOME/.gradle:/root/.gradle"            # cache do Gradle (leitura e escrita)
# -v "$HOME/.gemini-sandbox:/root/.gemini:ro" # APENAS uma copia dedicada de credenciais
```
Para ajustes persistentes e pessoais, use `.smolvm/*.local` ou `Smolfile.local`
(ignorados pelo git) e passe com `-s .smolvm/Smolfile.local`.

## Notas
- Egress restrito por `allow_hosts` (resolvido no start da VM; CDNs com IP rotativo podem exigir ajuste).
- Podman dentro da VM: o storage fica em `/var/lib/containers`, um diretorio no disco ext4 da VM.
- Limpeza: `smolvm machine stop --name agy && smolvm machine delete --name agy`.
