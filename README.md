# Dotfiles

Personal macOS and development environment setup managed with Nix, Home Manager,
and nix-darwin.

## Source Of Truth

- `nix/flake.nix` defines the flake inputs and the `homeConfigurations.cw` /
  `darwinConfigurations.cw` outputs.
- `nix/home.nix` links repo files into `~/.config`, `~/.claude`, `~/.codex`, and
  other home paths with out-of-store symlinks.
- Edit files in this repo, not the live copies under `$HOME`.

## Apply Changes

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
