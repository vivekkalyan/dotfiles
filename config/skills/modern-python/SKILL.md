---
name: modern-python
description: Configures Python projects with modern tooling (uv, ruff, ty). Use when creating projects, writing standalone scripts, or migrating from pip/Poetry/mypy/black.
---

# Modern Python

Guide for modern Python tooling and best practices.

## When to Use This Skill

- Creating a new Python project or package
- Setting up `pyproject.toml` configuration
- Configuring development tools (linting, formatting, testing)
- Writing Python scripts with external dependencies
- Migrating from legacy tools (when user requests it)

## When NOT to Use This Skill

- **User wants to keep legacy tooling**: Respect existing workflows if explicitly requested
- **Python < 3.11 required**: These tools target modern Python
- **Non-Python projects**: Mixed codebases where Python isn't primary

## Anti-Patterns to Avoid

| Avoid | Use Instead |
|-------|-------------|
| `[tool.ty]` python-version | `[tool.ty.environment]` python-version |
| `uv pip install` | `uv add` and `uv sync` |
| Editing pyproject.toml manually to add deps | `uv add <pkg>` / `uv remove <pkg>` |
| `hatchling` build backend | `uv_build` (simpler, sufficient for most cases) |
| Poetry | uv (faster, simpler, better ecosystem integration) |
| requirements.txt | PEP 723 for scripts, pyproject.toml for projects |
| mypy / pyright | ty (faster, from Astral team) |
| `[project.optional-dependencies]` for dev tools | `[dependency-groups]` (PEP 735) |
| Manual virtualenv activation (`source .venv/bin/activate`) | `uv run <cmd>` |
| pre-commit | prek (faster, no Python runtime needed) |

**Key principles:**
- Manage dependencies with `uv add` / `uv remove`; run commands with `uv run`.
- Use dependency groups for dev tools, commit `uv.lock`, and make `ruff`, `ty`, `pytest`, and `prek` project dev dependencies.
- Use local `uv run ...` hooks with `language: system`; use `uv run prek ...` in Makefiles, CI, and validation.
- Do not add `pytest-cov` or coverage config unless the user explicitly asks for coverage.

## Decision Tree

```
What are you doing?
│
├─ Single-file script with dependencies?
│   └─ Use PEP 723 inline metadata (./references/pep723-scripts.md)
│
├─ New multi-file project (not distributed)?
│   └─ Minimal uv setup (see Quick Start below)
│
├─ New reusable package/library?
│   └─ Full project setup (see Full Setup below)
│
└─ Migrating existing project?
    └─ See Migration Guide below
```

## Tool Overview

| Tool | Purpose | Replaces |
|------|---------|----------|
| **uv** | Package/dependency management | pip, virtualenv, pip-tools, pipx, pyenv |
| **ruff** | Linting AND formatting | flake8, black, isort, pyupgrade, pydocstyle |
| **ty** | Type checking | mypy, pyright (faster alternative) |
| **pytest** | Testing | unittest |
| **prek** | Pre-commit hooks ([setup](./references/prek.md)) | pre-commit (faster, Rust-native) |

For security hooks and audits, read [security-setup.md](./references/security-setup.md) only when needed.

## Quick Start: Minimal Project

For simple multi-file projects not intended for distribution:

```bash
# Create project with uv
uv init myproject
cd myproject

# Add dependencies
uv add requests rich

# Add dev dependencies
uv add --group dev pytest ruff ty prek

# Run code
uv run python src/myproject/main.py

# Run tools
uv run pytest
uv run ruff check .
uv run ty check
uv run prek run --all-files
```

## Full Project Setup

Use `uv init` for all new project scaffolds.

### 1. Create Project Structure

```bash
# For a named package
uv init --package myproject
cd myproject

# Or for the current directory
uv init --app --package .
```

### 2. Configure pyproject.toml

Use [pyproject.md](./references/pyproject.md). Defaults: `dev = ["prek", "pytest", "ruff", "ty"]`, Ruff on `src` and `tests`, strict pytest config, and `[tool.ty.environment] python-version`.

### 3. Configure Git Hooks

Use [templates/pre-commit-config.yaml](./templates/pre-commit-config.yaml) and [prek.md](./references/prek.md).

### 4. Install Dependencies

```bash
# Install all dependency groups
uv sync --all-groups

# Or install specific groups
uv sync --group dev
```

### 5. Add Makefile

Use the canonical template in [makefile.md](./references/makefile.md). It includes shell safety defaults, a `help` target powered by `##` docs, and standard Python project targets.

## Migration Guide

When a user requests migration from legacy tooling:

### From requirements.txt + pip

First, determine the nature of the code:

**For standalone scripts**: Convert to PEP 723 inline metadata (see [pep723-scripts.md](./references/pep723-scripts.md))

**For projects**:
```bash
# Initialize uv in existing project
uv init --bare

# Add dependencies using uv (not by editing pyproject.toml)
uv add requests rich  # add each package

# Or import from requirements.txt (review each package before adding)
grep -v '^#' requirements.txt | grep -v '^-' | grep -v '^\s*$' | while read -r pkg; do
    uv add "$pkg" || echo "Failed to add: $pkg"
done

uv sync
```

Then:
1. Delete `requirements.txt`, `requirements-dev.txt`
2. Delete virtual environment (`venv/`, `.venv/`)
3. Add `uv.lock` to version control

### From setup.py / setup.cfg

1. Run `uv init --bare` to create pyproject.toml
2. Use `uv add` to add each dependency from `install_requires`
3. Use `uv add --group dev` for dev dependencies
4. Copy non-dependency metadata (name, version, description, etc.) to `[project]`
5. Delete `setup.py`, `setup.cfg`, `MANIFEST.in`

### From flake8 + black + isort

1. Remove flake8, black, isort via `uv remove`
2. Delete `.flake8`, `pyproject.toml [tool.black]`, `[tool.isort]` configs
3. Add ruff: `uv add --group dev ruff`
4. Add ruff configuration (see [ruff-config.md](./references/ruff-config.md))
5. Run `uv run ruff check --fix .` to apply fixes
6. Run `uv run ruff format .` to format

### From mypy / pyright

1. Remove mypy/pyright via `uv remove`
2. Delete `mypy.ini`, `pyrightconfig.json`, or `[tool.mypy]`/`[tool.pyright]` sections
3. Add ty: `uv add --group dev ty`
4. Run `uv run ty check src/`

## Quick Reference: uv Commands

| Command | Description |
|---------|-------------|
| `uv init` | Create new project |
| `uv init --package` | Create distributable package |
| `uv add <pkg>` | Add dependency |
| `uv add --group dev <pkg>` | Add to dependency group |
| `uv remove <pkg>` | Remove dependency |
| `uv sync` | Install dependencies |
| `uv sync --all-groups` | Install all dependency groups |
| `uv run <cmd>` | Run command in venv |
| `uv run --with <pkg> <cmd>` | Run with temporary dependency |
| `uv build` | Build package |
| `uv publish` | Publish to PyPI |

### Ad-hoc Dependencies with `--with`

Use `uv run --with` for one-off commands that need packages not in your project:

```bash
# Run Python with a temporary package
uv run --with requests python -c "import requests; print(requests.get('https://httpbin.org/ip').json())"

# Multiple packages
uv run --with requests --with rich python script.py

# Combine with project deps (adds to existing venv)
uv run --with httpx pytest  # project deps + httpx
```

**When to use `--with` vs `uv add`:**
- `uv add`: Package is a project dependency (goes in pyproject.toml/uv.lock)
- `--with`: One-off usage, testing, or scripts outside a project context

See [uv-commands.md](./references/uv-commands.md) for complete reference.

## Best Practices Checklist

- [ ] Use `src/` layout for packages
- [ ] Set `requires-python = ">=3.11"`
- [ ] Configure ruff with selective rules (`["E", "F", "W", "I", "UP", "B", "SIM", "RUF", "C4", "PT"]`)
- [ ] Use ty for type checking
- [ ] Use dependency groups instead of extras for dev tools
- [ ] Add `uv.lock` to version control
- [ ] Use local `uv run` hooks for uv-managed tools in `.pre-commit-config.yaml`
- [ ] Use `uv run prek` in Makefiles and CI
- [ ] Use PEP 723 for standalone scripts

## Read Next

- [migration-checklist.md](./references/migration-checklist.md) - Step-by-step migration cleanup
- [pyproject.md](./references/pyproject.md) - Complete pyproject.toml reference
- [uv-commands.md](./references/uv-commands.md) - uv command reference
- [ruff-config.md](./references/ruff-config.md) - Ruff linting/formatting configuration
- [testing.md](./references/testing.md) - pytest setup; coverage is optional
- [pep723-scripts.md](./references/pep723-scripts.md) - PEP 723 inline script metadata
- [prek.md](./references/prek.md) - Fast pre-commit hooks with prek
- [security-setup.md](./references/security-setup.md) - Security hooks and dependency scanning
- [dependabot.md](./references/dependabot.md) - Automated dependency updates
