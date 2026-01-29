---
name: modern-python
description: Modern Python best practices. Use when creating new Python projects, writing Python scripts, or migrating existing projects from legacy tools.
---

# Modern Python Development

Use this guide when creating new Python projects, configuring `pyproject.toml`, setting up development tools, writing scripts with dependencies, or migrating from legacy tooling.

## Tool Stack

| Purpose | Tool | Replaces |
|---------|------|----------|
| Package management | `uv` | pip, virtualenv, pyenv, pip-tools, pipx |
| Linting & formatting | `ruff` | flake8, black, isort, pyupgrade, pydocstyle |
| Type checking | `ty` | mypy, pyright |
| Testing | `pytest` | unittest |
| Pre-commit hooks | `prek` | pre-commit |

## Critical Anti-Patterns

**Never do these:**

- `uv pip install <package>` → Use `uv add <package>` instead
- Manually edit `dependencies` in pyproject.toml → Use `uv add` / `uv remove`
- Use Poetry → Use `uv` instead
- Create requirements.txt → Use pyproject.toml with dependency groups
- Manually activate virtualenv → Use `uv run` for all commands
- Use setup.py or setup.cfg → Use pyproject.toml exclusively

## Project Setup

### New Package

```bash
uv init --package myproject
cd myproject
uv add --group dev ruff
uv add --group test pytest pytest-cov
uv sync
```

### New Script (PEP 723)

```bash
uv init --script myscript.py --python 3.12
```

## Running Commands

Always use `uv run` instead of activating environments:

```bash
uv run python src/myproject/main.py
uv run pytest
uv run ruff check .
uv run ruff format .
```

## Dependency Management

```bash
# Add runtime dependency
uv add requests

# Add dev dependency
uv add --group dev ruff

# Add test dependency
uv add --group test pytest

# Remove dependency
uv remove requests

# Update all dependencies
uv lock --upgrade

# Sync environment
uv sync
```

## Additional Resources

For detailed configuration and advanced usage:

- [pyproject.toml configuration](references/pyproject.md)
- [Ruff configuration](references/ruff-config.md)
- [uv command reference](references/uv-commands.md)
- [Testing with pytest](references/testing.md)
- [PEP 723 scripts](references/pep723-scripts.md)
- [Security setup](references/security-setup.md)
- [Migration checklist](references/migration-checklist.md)
- [prek pre-commit hooks](references/prek.md)
- [Dependabot configuration](references/dependabot.md)
