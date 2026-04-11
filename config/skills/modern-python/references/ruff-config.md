# Ruff Configuration Reference

Ruff is an extremely fast Python linter and formatter written in Rust. It replaces flake8, black, isort, pyupgrade, pydocstyle, and many other tools.

## Basic Setup

Add to `pyproject.toml`:

```toml
[tool.ruff]
line-length = 100
# target-version is inferred from requires-python, no need to set it
src = ["src", "tests"]

[tool.ruff.lint]
select = ["E", "F", "W", "I", "UP", "B", "SIM", "RUF", "C4", "PT"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```

## Running Ruff

```bash
# Lint
uv run ruff check .
uv run ruff check --fix .        # Auto-fix
uv run ruff check --fix --unsafe-fixes .  # Including unsafe fixes

# Format
uv run ruff format .
uv run ruff format --check .     # Check only
uv run ruff format --diff .      # Show diff
```

## Rule Categories

Using `select = ["ALL"]` enables all rules. Common categories:

| Code | Category | Description |
|------|----------|-------------|
| `E`, `W` | pycodestyle | Style errors and warnings |
| `F` | Pyflakes | Logical errors |
| `I` | isort | Import sorting |
| `N` | pep8-naming | Naming conventions |
| `D` | pydocstyle | Docstring conventions |
| `UP` | pyupgrade | Python upgrade suggestions |
| `B` | flake8-bugbear | Bug detection |
| `S` | flake8-bandit | Security issues |
| `A` | flake8-builtins | Built-in shadowing |
| `C4` | flake8-comprehensions | Comprehension improvements |
| `DTZ` | flake8-datetimez | Timezone-aware datetime |
| `T10` | flake8-debugger | Debugger statements |
| `T20` | flake8-print | Print statements |
| `PT` | flake8-pytest-style | Pytest style |
| `Q` | flake8-quotes | Quote consistency |
| `SIM` | flake8-simplify | Simplification suggestions |
| `TID` | flake8-tidy-imports | Import hygiene |
| `ARG` | flake8-unused-arguments | Unused arguments |
| `ERA` | eradicate | Commented-out code |
| `PL` | Pylint | Pylint rules |
| `RUF` | Ruff-specific | Ruff's own rules |
| `ANN` | flake8-annotations | Type annotation checks |

## Per-File Ignores

Only needed if you add additional rule categories beyond the default select:

```toml
[tool.ruff.lint.per-file-ignores]
# __init__.py
"__init__.py" = [
    "F401",     # unused imports (re-exports)
]
```

## If Using `select = ["ALL"]`

For non-ML projects that want exhaustive linting, use `select = ["ALL"]` with these ignores:

```toml
[tool.ruff.lint]
select = ["ALL"]
ignore = [
    "D",        # pydocstyle
    "COM812",   # trailing comma (formatter conflict)
    "ISC001",   # string concat (formatter conflict)
    "ANN",      # annotations — let ty handle type checking
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = [
    "S101",     # assert usage
    "PLR2004",  # magic values
]
```

## Import Sorting (isort)

```toml
[tool.ruff.lint.isort]
force-single-line = false
known-first-party = ["myproject"]
required-imports = ["from __future__ import annotations"]
section-order = [
    "future",
    "standard-library",
    "third-party",
    "first-party",
    "local-folder",
]
```

## Docstring Style (pydocstyle)

If enabling docstring checks:

```toml
[tool.ruff.lint]
select = ["D"]
ignore = [
    "D100",     # Missing module docstring
    "D104",     # Missing public package docstring
    "D203",     # 1 blank line before class docstring (conflicts D211)
    "D213",     # Multi-line summary second line (conflicts D212)
]

[tool.ruff.lint.pydocstyle]
convention = "google"  # or "numpy", "pep257"
```

## Formatter Configuration

```toml
[tool.ruff.format]
quote-style = "double"           # or "single"
indent-style = "space"           # or "tab"
skip-magic-trailing-comma = false
line-ending = "auto"             # or "lf", "crlf"
```

## Type Checking

Ruff does NOT do type checking. Use **ty** (from Astral, the same team behind ruff and uv):

```bash
# Add ty to dev dependencies
uv add --group dev ty

# Run type checking
uv run ty check src/
```

ty is significantly faster than mypy or pyright and integrates well with the modern Python toolchain.

## CI Configuration

```yaml
# GitHub Actions
- name: Lint
  run: uv run ruff check --output-format=github .

- name: Format check
  run: uv run ruff format --check .
```

## Migration from Other Tools

### From flake8

Ruff covers most flake8 plugins. Remove:
- flake8
- flake8-* plugins
- .flake8 config file

### From black

Remove black and use `ruff format`. Remove:
- black
- [tool.black] config

### From isort

Ruff includes isort. Remove:
- isort
- [tool.isort] config

Use `[tool.ruff.lint.isort]` for isort settings.

## Code Modernization

Run pyupgrade rules to modernize syntax to your target Python version:

```bash
uv run ruff check --select=UP --fix .  # Auto-fix upgrades
uv run ruff check --select=UP .        # Preview only
```

Common modernizations include:
- `typing.Optional[X]` -> `X | None`
- `typing.List[X]` -> `list[X]`
- `super(ClassName, self)` -> `super()`
- Format strings and other syntax upgrades

## Line Length Migration

If migrating from 120 to 100 char lines, expect manual fixes.
For less churn during initial migration, keep existing:

```toml
line-length = 120  # Match existing; tighten later
```
