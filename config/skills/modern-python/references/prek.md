# prek: Fast Pre-commit Hooks

[prek](https://github.com/j178/prek) is a fast, Rust-native drop-in replacement for pre-commit. It uses the same `.pre-commit-config.yaml` format and is fully compatible with existing configurations.

## Why prek over pre-commit?

| Feature | prek | pre-commit |
|---------|------|------------|
| Speed | ~7x faster hook installation | Slower |
| Dependencies | Single binary, no runtime needed | Requires Python |
| Disk usage | Shared toolchains between hooks | Isolated environments |
| Parallelism | Parallel repo cloning and hook execution | Sequential |
| Python management | Uses uv automatically | Manual Python setup |
| Monorepo support | Built-in workspace mode | Not supported |

## Installation

See [security-setup.md](./security-setup.md) for installation options.

## Quick Start

### For uv-managed repos

Add `prek` as a project dev dependency and run it through `uv`:

```bash
uv add --group dev prek
uv run prek install
uv run prek run --all-files
```

This keeps the runner version in `uv.lock`, matching the rest of the project tooling.

### For Existing pre-commit Users

prek is fully compatible with `.pre-commit-config.yaml`. Just replace commands:

```bash
# Instead of: pre-commit install
uv run prek install

# Instead of: pre-commit run --all-files
uv run prek run --all-files

# Instead of: pre-commit autoupdate
uv run prek auto-update
```

### New Setup

1. Create `.pre-commit-config.yaml` (see [templates/pre-commit-config.yaml](../templates/pre-commit-config.yaml))

2. Install and run:

```bash
# Install git hooks
uv run prek install

# Run manually on all files
uv run prek run --all-files

# Run specific hook
uv run prek run ruff-check
```

## Configuration

### Using Built-in Hooks

prek includes Rust-native implementations of common hooks for extra speed:

```yaml
repos:
  - repo: builtin
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-toml
```

## Commands

When `prek` is a project dev dependency, run these as `uv run prek ...`.

| Command | Description |
|---------|-------------|
| `prek install` | Install git hooks |
| `prek uninstall` | Remove git hooks |
| `prek run` | Run hooks on staged files |
| `prek run --all-files` | Run on all files |
| `prek run --last-commit` | Run on last commit's files |
| `prek run HOOK [HOOK...]` | Run specific hook(s) |
| `prek run -d src/` | Run on files in directory |
| `prek auto-update` | Update hook versions |
| `prek list` | List configured hooks |
| `prek clean` | Remove cached environments |

## CI Configuration

### GitHub Actions

```yaml
name: CI
on: [push, pull_request]

jobs:
  checks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@<sha>  # <latest> https://github.com/actions/checkout/releases
      - uses: astral-sh/setup-uv@<sha>  # <latest> https://github.com/astral-sh/setup-uv/releases
        with:
          enable-cache: true
      - name: Install Python
        run: uv python install
      - name: Install dependencies
        run: uv sync --locked --all-groups
      - name: Run hooks
        run: uv run prek run --all-files
      - name: Run tests
        run: uv run pytest
```

Use `j178/prek-action` only when `prek` is not a project dependency.

## Makefile Integration

Add these targets to the canonical template in [makefile.md](./makefile.md):

```makefile
.PHONY: hooks hooks-install

hooks: ## Run all pre-commit hooks
	uv run prek run --all-files

hooks-install: ## Install pre-commit hooks
	uv run prek install
```

## Migration from pre-commit

1. Add prek to the project: `uv add --group dev prek`
2. Remove pre-commit: `pip uninstall pre-commit` or `uv tool uninstall pre-commit`
3. Re-install hooks: `uv run prek install`
4. (Optional) Clean old environments: `rm -rf ~/.cache/pre-commit`

Your existing `.pre-commit-config.yaml` works unchanged.

## Best Practices

1. **Use `uv run prek run --all-files` in CI** - Ensures all files are checked, not just changed ones
2. **Use local hooks for uv-managed tools** - Keep ruff, ty, and prek versions in `uv.lock`
3. **Pin external hook repos** - For non-local hooks, use specific `rev` values, not branches
4. **Use `--cooldown-days` for external hook updates** - Mitigates supply chain attacks: `uv run prek auto-update --cooldown-days 7`
5. **Prefer built-in hooks** - Use `repo: builtin` for common checks (faster, offline)
6. **Run hooks before commit** - `uv run prek install` sets this up automatically
7. **Initialize detect-secrets baseline** - Run `detect-secrets scan > .secrets.baseline` before first commit
