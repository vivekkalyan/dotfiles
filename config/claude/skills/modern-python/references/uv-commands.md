# uv Command Reference

`uv` is an extremely fast Python package and project manager written in Rust. It replaces pip, virtualenv, pip-tools, pipx, and pyenv.

**Key principle:** Never manually activate or manage virtual environments—use `uv run` for all commands.

## Installation

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Homebrew
brew install uv

# Windows
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## Project Initialization

```bash
# Standard application
uv init myapp
cd myapp

# Distributable package with src layout
uv init --package mylib
cd mylib

# Library (no entry point)
uv init --lib mylib

# PEP 723 script
uv init --script myscript.py --python 3.12
```

## Dependency Management

```bash
# Add runtime dependency
uv add requests

# Add specific version
uv add "requests>=2.31,<3"

# Add to dependency group
uv add --group dev ruff
uv add --group test pytest pytest-cov

# Add optional feature
uv add --optional cli click

# Remove dependency
uv remove requests

# Update lock file
uv lock

# Upgrade all dependencies
uv lock --upgrade

# Upgrade specific package
uv lock --upgrade-package requests
```

## Environment Sync

```bash
# Sync all default groups
uv sync

# Sync specific groups
uv sync --group dev --group test

# Sync without dev groups (production)
uv sync --no-group dev

# Frozen install (fail if lock outdated)
uv sync --frozen

# Locked install (use exact lock file)
uv sync --locked
```

## Running Commands

```bash
# Run Python
uv run python

# Run module
uv run python -m mymodule

# Run script
uv run python src/myproject/main.py

# Run pytest
uv run pytest

# Run with extra dependency (not added to project)
uv run --with httpx python -c "import httpx; print(httpx.__version__)"
```

## Python Version Management

```bash
# Install Python version
uv python install 3.12

# List installed versions
uv python list

# Pin project Python version
uv python pin 3.12

# Run with specific version
uv run --python 3.12 python --version
```

## Tool Management

```bash
# Run tool without installing
uvx ruff check .

# Same as above (long form)
uv tool run ruff check .

# Install tool globally
uv tool install ruff

# List installed tools
uv tool list

# Upgrade tool
uv tool upgrade ruff
```

## Common Workflows

### Application Development

```bash
uv init myapp
cd myapp
uv add fastapi uvicorn
uv add --group dev ruff
uv add --group test pytest httpx
uv sync
uv run uvicorn myapp:app --reload
```

### Library Development

```bash
uv init --package mylib
cd mylib
uv add --group dev ruff
uv add --group test pytest pytest-cov
uv sync
uv run pytest
```

### One-off Script

```bash
uv run --with requests --with beautifulsoup4 python scrape.py
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `UV_CACHE_DIR` | Cache directory location |
| `UV_PYTHON` | Default Python version |
| `UV_PROJECT_ENVIRONMENT` | Custom venv location |
| `UV_SYSTEM_PYTHON` | Allow system Python |
