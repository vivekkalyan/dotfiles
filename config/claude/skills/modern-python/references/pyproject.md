# pyproject.toml Configuration Reference

## Complete Example

```toml
[project]
name = "myproject"
version = "0.1.0"
description = "A modern Python project"
readme = "README.md"
license = "MIT"
requires-python = ">=3.12"
authors = [{ name = "Your Name", email = "you@example.com" }]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Programming Language :: Python :: 3.12",
]
dependencies = [
    "requests>=2.31,<3",
]

[project.optional-dependencies]
# Only use for optional *runtime* features that end users install
# NOT for dev tools
cli = ["click>=8.0,<9"]

[project.scripts]
myproject = "myproject.cli:main"

[build-system]
requires = ["uv_build>=0.9,<1"]
build-backend = "uv_build"

[dependency-groups]
dev = ["ruff>=0.8"]
test = ["pytest>=8.0", "pytest-cov>=6.0", "hypothesis>=6.0"]

[tool.uv]
default-groups = ["dev", "test"]

[tool.ruff]
line-length = 100
target-version = "py312"

[tool.ruff.lint]
select = ["E", "F", "W", "I", "N", "B", "A", "C4", "SIM", "ARG"]

[tool.pytest.ini_options]
testpaths = ["tests"]
pythonpath = ["src"]
addopts = "-ra --cov=myproject --cov-report=term-missing --cov-fail-under=80"

[tool.coverage.run]
branch = true
source = ["src/myproject"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.:",
]
</toml>
```

## Section Reference

### [project] - PEP 621 Metadata

Core project information. All fields are standard and portable across tools.

| Field | Description |
|-------|-------------|
| `name` | Package name (lowercase, hyphens) |
| `version` | Semantic version |
| `description` | One-line summary |
| `requires-python` | Minimum Python version |
| `dependencies` | Runtime dependencies |

### [project.optional-dependencies]

Optional *runtime* features users can install:

```bash
uv add myproject[cli]
```

**Important:** Only use for optional runtime features, not development tools. Use `[dependency-groups]` for dev/test tools.

### [project.scripts]

Console entry points for CLI applications:

```toml
[project.scripts]
myproject = "myproject.cli:main"
```

### [build-system]

Use `uv_build` as the build backend:

```toml
[build-system]
requires = ["uv_build>=0.9,<1"]
build-backend = "uv_build"
```

### [dependency-groups] - PEP 735

Development dependencies installed via `uv sync` but not for end users:

```toml
[dependency-groups]
dev = ["ruff>=0.8"]
test = ["pytest>=8.0", "pytest-cov>=6.0"]
docs = ["sphinx>=7.0", "furo>=2024.0"]
```

### [tool.uv]

Configure uv behavior:

```toml
[tool.uv]
default-groups = ["dev", "test"]  # Groups synced by default
```

## Dependency Version Specifiers

```toml
dependencies = [
    "requests>=2.31,<3",        # Range constraint (recommended)
    "click>=8.0",               # Minimum only
    "numpy~=1.26.0",            # Compatible release (~= 1.26.*)
]
```

## Lock File Strategy

| Project Type | Commit uv.lock? |
|--------------|-----------------|
| Application | Yes - reproducible deployments |
| Library | No - add to .gitignore |

## Key Rules

1. **Always use `uv add` and `uv remove`** to manage dependencies
2. **Never manually edit** `dependencies` or `dependency-groups` sections
3. **Use dependency groups** for dev/test tools, not optional-dependencies
4. **Pin version ranges** like `>=1.0,<2` for stability
