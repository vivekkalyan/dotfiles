# Migration Checklist

Migrate existing Python projects to modern tooling.

## Pre-Migration

- [ ] Decide on project layout: `src/` layout (recommended) or flat
- [ ] Decide on lock strategy: commit `uv.lock` (apps) or gitignore (libraries)
- [ ] Create backup branch: `git checkout -b pre-migration-backup`

## Remove Legacy Files

### Find and Remove

```bash
# Find legacy config files
ls -la setup.py setup.cfg MANIFEST.in requirements*.txt Pipfile* poetry.lock .python-version

# Find legacy tool configs in pyproject.toml
grep -E "^\[tool\.(black|isort|flake8|mypy|pylint)\]" pyproject.toml

# Find legacy pragmas in code
rg "# pylint:|# noqa:|# type: ignore" --type py

# Remove legacy files
rm -f setup.py setup.cfg MANIFEST.in requirements*.txt Pipfile Pipfile.lock poetry.lock .python-version

# Remove old virtual environments
rm -rf venv .venv env .env
```

### Remove Legacy Dependencies

```bash
uv remove black isort flake8 pylint mypy pyright autoflake pyupgrade
```

## Update .gitignore

```gitignore
# Python
__pycache__/
*.py[cod]
*.so
.Python
build/
dist/
*.egg-info/

# Virtual environments (uv manages these)
.venv/

# Tool caches
.ruff_cache/
.pytest_cache/
.coverage
htmlcov/

# Lock file (uncomment for libraries)
# uv.lock
```

## Update pyproject.toml

### Remove Legacy Tool Sections

Delete these sections if present:
- `[tool.black]`
- `[tool.isort]`
- `[tool.flake8]`
- `[tool.mypy]`
- `[tool.pylint]`

### Add Modern Configuration

See [pyproject.md](pyproject.md) for complete configuration.

## Modernize Code

Run automatic fixes:

```bash
# Upgrade Python syntax
uv run ruff check . --select UP --fix

# Remove unnecessary return statements
uv run ruff check . --select RET504 --fix

# Simplify code
uv run ruff check . --select SIM --fix

# Remove dead code
uv run ruff check . --select ERA --fix --unsafe-fixes
```

## Type Checking

### Gradual Adoption

Start with lenient rules:

```toml
[tool.ty]
strict = false
```

Then progressively enable:

```bash
# Check current state
uv run ty check src/

# Fix issues incrementally
# Enable stricter rules as errors are resolved
```

## Security Setup

```bash
# Install prek
brew install prek

# Copy template
cp ~/.claude/skills/modern-python/templates/pre-commit-config.yaml .pre-commit-config.yaml

# Initialize detect-secrets baseline
detect-secrets scan > .secrets.baseline

# Install hooks
prek install

# Run on all files
prek run --all-files
```

## Update CI

Replace old commands:

| Old | New |
|-----|-----|
| `pip install -r requirements.txt` | `uv sync --frozen` |
| `pip install -e .` | `uv sync` |
| `python -m pytest` | `uv run pytest` |
| `black --check .` | `uv run ruff format --check .` |
| `flake8 .` | `uv run ruff check .` |
| `mypy src/` | `uv run ty check src/` |

Example GitHub Actions:

```yaml
- uses: astral-sh/setup-uv@v4

- name: Install dependencies
  run: uv sync --frozen

- name: Lint
  run: uv run ruff check .

- name: Format check
  run: uv run ruff format --check .

- name: Type check
  run: uv run ty check src/

- name: Test
  run: uv run pytest
```

## Verification

```bash
# Sync dependencies
uv sync

# Run linting
uv run ruff check .

# Run formatting
uv run ruff format .

# Run type checking
uv run ty check src/

# Run tests
uv run pytest

# Run pre-commit hooks
prek run --all-files
```

## Final Cleanup

- [ ] Remove migration backup branch after verification
- [ ] Update README with new commands
- [ ] Update CONTRIBUTING guide if present
- [ ] Notify team of new workflow
