# Dotfiles

Personal macOS and dev-pod environment setup managed with Nix, Home Manager,
nix-darwin, and Kubernetes manifests.

## Start Here

- [AGENTS.md](AGENTS.md): repo conventions for agents and humans.
- [nix/flake.nix](nix/flake.nix): flake outputs for `cw` on macOS and `vivek-dev` on Linux.
- [nix/home.nix](nix/home.nix): main ownership map for linked config files and packages.
- [k8s/vivek-dev/](k8s/vivek-dev): source-controlled Kubernetes resources for the GPU dev pod.

Edit files in this repo, not the live copies under `$HOME`. If you add, rename,
or remove a managed config file, update [nix/home.nix](nix/home.nix).

## Mac Setup

Cheap Home Manager eval:

```sh
nix --extra-experimental-features 'nix-command flakes' eval ./nix#homeConfigurations.cw.activationPackage.drvPath
```

Build the full macOS system without switching:

```sh
darwin-rebuild build --flake ./nix#cw
```

Apply the macOS system:

```sh
darwin-rebuild switch --flake ./nix#cw
```

Or use the repo wrapper:

```sh
dotfiles-apply --target mac
```

## Dev Pod

The dev pod is `Deployment/default/vivek-dev` in Kubernetes context `cks-wb3`.
It mounts `PVC/default/vivek-dev-workspace` at `/workspace` and `/root`.

Entrypoints:

- [k8s/vivek-dev/README.md](k8s/vivek-dev/README.md): Kubernetes manifests and required Secrets.
- [CoreWeave Dev Workspace](/Users/vkalyan/personal/brain/efforts/projects/1780641941.md): workspace notes and links.

Common commands:

```sh
ssh vivek-dev
kubectl diff -k k8s/vivek-dev
kubectl apply -k k8s/vivek-dev
kubectl rollout status deployment/vivek-dev -n default
kubectl scale deployment/vivek-dev -n default --replicas=0
kubectl scale deployment/vivek-dev -n default --replicas=1
```

Apply Home Manager inside the pod:

```sh
cd /workspace/personal/dotfiles/nix
nix build .#homeConfigurations.vivek-dev.activationPackage -o /tmp/vivek-dev-home
/tmp/vivek-dev-home/activate
```

From the Mac, pull the latest pushed dotfiles on the pod and apply them:

```sh
dev-pod-apply
```

Use `dev-pod-apply --check` to build on the pod without activating.

Secrets are not committed. The required secret names and recreation commands live
in [k8s/vivek-dev/README.md](k8s/vivek-dev/README.md).

## Updates

Update scripts change the repo first; apply scripts make a machine match the
current repo checkout.

```sh
dotfiles-update --dry-run
dotfiles-update
dotfiles-update flake nixpkgs-unstable
dotfiles-update check
```

Bare `dotfiles-update` updates all dotfiles-managed pins and flake inputs.
Review and commit the diff, push it, then run `dev-pod-apply`.


## Repo Map

- [config/nvim/](config/nvim): Neovim config.
- [config/git/](config/git): Git config and ignore rules.
- [config/zsh/](config/zsh): zsh entrypoints and shell config.
- [config/tmux/](config/tmux): tmux config.
- [system/](system): shell fragments sourced by zsh.
- [bin/](bin): personal scripts on PATH.
- [nix/bootstrap.sh](nix/bootstrap.sh): fresh-machine bootstrap for macOS.
- `~/personal/skills`: Agent Skills repo

## SSH Commit Signing

Git signs commits with the SSH key at `~/.ssh/github`. On macOS, store that key's
passphrase in Keychain once:

```sh
/usr/bin/ssh-add --apple-use-keychain ~/.ssh/github
```

Use `/usr/bin/ssh-add` so the Apple Keychain flags are available even when the
Nix OpenSSH package appears earlier in `PATH`.

New interactive shells source `system/ssh.zsh`, which quietly loads that key from
Keychain into `ssh-agent` when needed. Check the agent with:

```sh
ssh-add -l
```

## Commit Style

Use `[scope]: description`.

Common scopes: `nix`, `k8s`, `nvim`, `zsh`, `git`, `claude`, `skills`, `clean`.
