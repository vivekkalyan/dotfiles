# prek: Fast Pre-commit Hooks

prek is a Rust-based alternative to pre-commit that's ~7x faster while remaining compatible with existing `.pre-commit-config.yaml` files.

## Features

- **7x faster** hook installation than pre-commit
- **Single binary** - no Python runtime dependency
- **Parallel execution** of repository cloning and hooks
- **Automatic Python management** via uv
- **Built-in hooks** for common operations (Rust-native, extra fast)
- **Monorepo support** built-in

## Installation

```bash
# Homebrew (recommended)
brew install prek

# Cargo
cargo install prek

# Shell script
curl -sSf https://raw.githubusercontent.com/astral-sh/prek/main/scripts/install.sh | sh
```

## Quick Start

```bash
# Install hooks
prek install

# Run on all files
prek run --all-files

# Update hook versions
prek auto-update
```

## Commands

| Command | Description |
|---------|-------------|
| `prek install` | Install git hooks |
| `prek uninstall` | Remove git hooks |
| `prek run` | Run hooks on staged files |
| `prek run --all-files` | Run hooks on all files |
| `prek run --files <path>` | Run hooks on specific files |
| `prek run --from-ref <ref> --to-ref <ref>` | Run on changed files between refs |
| `prek auto-update` | Update hook versions |
| `prek list-hooks` | List configured hooks |
| `prek clean` | Clear cache |

## Configuration

Use the same `.pre-commit-config.yaml` format as pre-commit.

See [templates/pre-commit-config.yaml](../templates/pre-commit-config.yaml) for a recommended setup.

### Built-in Hooks

prek provides Rust-native implementations of common hooks for better performance:

```yaml
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v5.0.0
  hooks:
    - id: trailing-whitespace    # Built-in
    - id: end-of-file-fixer      # Built-in
    - id: check-yaml             # Built-in
    - id: check-toml             # Built-in
    - id: check-merge-conflict   # Built-in
    - id: check-added-large-files
      args: [--maxkb=1000]
```

## GitHub Actions

```yaml
- name: Install prek
  run: uv tool install prek

- name: Run pre-commit hooks
  run: prek run --all-files
```

Or use the dedicated action:

```yaml
- uses: astral-sh/prek-action@v1
  with:
    args: run --all-files
```

## Migration from pre-commit

```bash
# Install prek
brew install prek

# Uninstall pre-commit hooks
pre-commit uninstall

# Optionally remove pre-commit
pip uninstall pre-commit

# Install prek hooks
prek install

# Verify
prek run --all-files
```

No configuration changes needed - prek reads the same `.pre-commit-config.yaml`.

## Best Practices

1. **Run all-files in CI** - Catch issues not in staged changes
2. **Pin hook versions** - Use specific revs, not branches
3. **Use cooldown for updates** - Don't auto-update immediately
4. **Leverage built-in hooks** - They're faster than Python equivalents
5. **Initialize detect-secrets baseline** - Before first commit

```bash
# Initialize baseline for detect-secrets
detect-secrets scan > .secrets.baseline
git add .secrets.baseline
```
