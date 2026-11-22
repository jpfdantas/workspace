# Sandbox `smolvm` para o Antigravity CLI (`agy`)

Imagem Debian trixie com Podman, ferramentas basicas e o `agy`.
O `Smolfile` e a imagem **nao contem segredos nem caminhos pessoais**.

Rode todos os comandos **a partir da raiz do repositorio** (o mount `.:/workspace` e relativo ao diretorio atual).

## 1. Build da imagem
Feito automaticamente pelo `.smolvm/start.sh` (equivale a):
```bash
podman build -t localhost/dev-sandbox:latest -f .devcontainer/Containerfile .
```
> Se o Podman reclamar de `registries.conf must be in v2 format`, converta seu
> `~/.config/containers/registries.conf` para `unqualified-search-registries = ["docker.io"]`.

## 2. Ciclo de vida da VM
```bash
.smolvm/start.sh    # builda, cria (se preciso), inicia e entra na VM
.smolvm/stop.sh     # para a VM
.smolvm/delete.sh   # para e deleta a VM
```
Veja "Credenciais OAuth" abaixo. Para aplicar uma imagem nova: `delete.sh` e depois `start.sh`.

## 3. Executar o `agy` headless
```bash
smolvm machine exec --name agy -- \
  agy -p "sua tarefa"
```

## Credenciais OAuth (nada de segredo dentro da VM)
O `agy` usa OAuth da conta Google (sem API key). No host o `agy` guarda o OAuth no keyring (Secret Service). A VM so tem o arquivo
`~/.gemini/antigravity-cli/antigravity-oauth-token` **sintetico** (placeholder + refresh token falso). O `Smolfile` declara a credencial
`AGY_ACCESS_TOKEN`: o `smolvm` troca o placeholder pelo `Bearer <token>` real do host,
apenas em HTTPS para `cloudcode-pa.googleapis.com` e `generativelanguage.googleapis.com`.

```bash
agy                      # no HOST: faz login/renova o token no keyring (lido via secret-tool)
.smolvm/start.sh         # cria/inicia a VM, escreve o arquivo sintetico e entra
.smolvm/start.sh         # ~1h depois (token expira) ou em caso de 401: com a VM rodando, so renova a credencial
```
O token real nunca e impresso nem gravado em disco pelos scripts. Refresh token real nunca sai do host.

**Nao monte o seu `~/.gemini` real.**

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
- Limpeza: `.smolvm/delete.sh`.
