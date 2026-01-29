# Ruff Configuration Reference

Ruff is an extremely fast Python linter and formatter written in Rust. It replaces flake8, black, isort, pyupgrade, pydocstyle, and many other tools.

## Basic Configuration

```toml
[tool.ruff]
line-length = 100
target-version = "py312"
src = ["src", "tests"]

[tool.ruff.lint]
select = [
    "E",      # pycodestyle errors
    "W",      # pycodestyle warnings
    "F",      # Pyflakes
    "I",      # isort
    "N",      # pep8-naming
    "B",      # flake8-bugbear
    "A",      # flake8-builtins
    "C4",     # flake8-comprehensions
    "SIM",    # flake8-simplify
    "ARG",    # flake8-unused-arguments
    "PTH",    # flake8-use-pathlib
    "UP",     # pyupgrade
]
ignore = [
    "COM812", # Conflicts with formatter
    "ISC001", # Conflicts with formatter
]

[tool.ruff.lint.per-file-ignores]
"tests/**/*.py" = ["S101", "ARG001"]  # Allow assert and unused args
"scripts/**/*.py" = ["T201"]          # Allow print
"__init__.py" = ["F401"]              # Allow unused imports

[tool.ruff.lint.isort]
force-single-line = true
known-first-party = ["myproject"]

[tool.ruff.lint.pydocstyle]
convention = "google"

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
docstring-code-format = true
```

## Commands

```bash
# Check for issues
uv run ruff check .

# Check and auto-fix
uv run ruff check . --fix

# Check with unsafe fixes
uv run ruff check . --fix --unsafe-fixes

# Format code
uv run ruff format .

# Check formatting without changes
uv run ruff format . --check

# Show diff of format changes
uv run ruff format . --diff
```

## Rule Categories

| Code | Source | Description |
|------|--------|-------------|
| E, W | pycodestyle | Style errors and warnings |
| F | Pyflakes | Logical errors |
| I | isort | Import sorting |
| N | pep8-naming | Naming conventions |
| D | pydocstyle | Docstring conventions |
| B | flake8-bugbear | Bug-prone patterns |
| S | flake8-bandit | Security issues |
| A | flake8-builtins | Builtin shadowing |
| C4 | flake8-comprehensions | Comprehension improvements |
| DTZ | flake8-datetimez | Timezone-aware datetime |
| T10 | flake8-debugger | Debugger statements |
| T20 | flake8-print | Print statements |
| PT | flake8-pytest-style | Pytest style |
| Q | flake8-quotes | Quote consistency |
| SIM | flake8-simplify | Simplification suggestions |
| ARG | flake8-unused-arguments | Unused arguments |
| PTH | flake8-use-pathlib | Pathlib usage |
| UP | pyupgrade | Python upgrade suggestions |
| RET | flake8-return | Return statement issues |
| ERA | eradicate | Commented-out code |

## Important Notes

**Ruff does NOT do type checking.** Use `ty` for type validation:

```bash
uv add --group dev ty
uv run ty check src/
```

## Migration from Legacy Tools

Remove these from pyproject.toml:
- `[tool.black]`
- `[tool.isort]`
- `[tool.flake8]`

Remove these dependencies:
```bash
uv remove black isort flake8 pylint pyupgrade
```

## GitHub Actions

```yaml
- name: Lint
  run: uv run ruff check . --output-format=github

- name: Format check
  run: uv run ruff format . --check
```
