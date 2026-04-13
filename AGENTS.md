# Dotfiles

## Source Of Truth

- [`nix/flake.nix`](nix/flake.nix) defines the flake inputs and the `homeConfigurations.cw` / `darwinConfigurations.cw` outputs.
- [`nix/home.nix`](nix/home.nix) is the main ownership map: it links repo files into `~/.config`, `~/.claude`, `~/.codex`, and other home paths via out-of-store symlinks.
- Edit files in this repo, not the live copies under `$HOME`.
- If you add, rename, or remove a managed config file, update [`nix/home.nix`](nix/home.nix).

## Repo Map

- [`config/nvim/`](config/nvim): Neovim config. [`config/nvim/init.lua`](config/nvim/init.lua) loads [`config/nvim/lua/vivek/core/`](config/nvim/lua/vivek/core) and [`config/nvim/lua/vivek/plugins/`](config/nvim/lua/vivek/plugins). LSP lives in [`config/nvim/lua/vivek/plugins/lsp/`](config/nvim/lua/vivek/plugins/lsp), formatting in [`config/nvim/lua/vivek/plugins/format.lua`](config/nvim/lua/vivek/plugins/format.lua), linting in [`config/nvim/lua/vivek/plugins/lint.lua`](config/nvim/lua/vivek/plugins/lint.lua).
- [`config/claude/`](config/claude): Claude-specific settings, commands, hooks, and statusline copied into `~/.claude`. Start with [`config/claude/settings.json`](config/claude/settings.json) and [`config/claude/commands/`](config/claude/commands). Hooks currently wrap bare `python` / `sky` commands to `uv run ...`.
- [`config/skills/`](config/skills): Shared Agent Skills tree linked into `~/.claude/skills`, with each repo skill symlinked into `~/.codex/skills/user/` alongside Codex's existing `.system` skills.
- [`config/git/`](config/git), [`config/zsh/`](config/zsh), [`config/tmux/`](config/tmux), [`config/ghostty/`](config/ghostty), [`config/karabiner/`](config/karabiner): tool-specific configs.
- [`system/`](system): shell fragments sourced by zsh (`path`, `alias`, `functions`, prompt/fzf/history helpers).
- [`bin/`](bin): personal scripts on PATH. Python helpers use `uv run --script` with inline metadata.
- [`nix/bootstrap.sh`](nix/bootstrap.sh): fresh-machine bootstrap for macOS, Nix, Homebrew, repo clone/update, and `darwin-rebuild switch`.

## Editing Rules

- Preserve the repo's existing lightweight, hand-written style; avoid unnecessary refactors.
- Edit source files in this repo, not live copies under `$HOME`. If you add, move, or remove a managed config, update [`nix/home.nix`](nix/home.nix).
- Do not edit generated/local state: `config/zsh/.zcompdump`, `config/git/config-os`.
- Only change [`config/nvim/lazy-lock.json`](config/nvim/lazy-lock.json) or [`nix/flake.lock`](nix/flake.lock) when intentionally updating plugins or flake inputs.

## Verification

- Flake commands here need `nix --extra-experimental-features 'nix-command flakes' ...`.
- Cheap check: `nix --extra-experimental-features 'nix-command flakes' eval ./nix#homeConfigurations.cw.activationPackage.drvPath`
- Stronger non-sudo check: `darwin-rebuild build --flake ./nix#cw`
- Do not run `darwin-rebuild switch` or [`nix/bootstrap.sh`](nix/bootstrap.sh) unless explicitly asked; they require sudo/user interaction here.

## Commits

Use the format `[scope]: description` where scope identifies the tool/config being changed.

Examples from this repo:
- `[nvim]: Disable inlay hints by default`
- `[claude]: Add skill-creator skill`
- `[nix]: Add gh package`
- `[clean]: Remove unused configs`

Common scopes: `nvim`, `claude`, `nix` (nix/home-manager), `git`, `clean`
