# Testing with pytest

Configuration and best practices for pytest. Coverage is optional; do not add it unless the user asks for it or the project already enforces it.

## Setup

Add test dependencies:

```bash
uv add --group dev pytest
```

## pyproject.toml Configuration

```toml
[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = ["-q", "--strict-markers", "--strict-config"]
markers = [
    "slow: marks tests as slow",
    "integration: marks integration tests",
]
filterwarnings = [
    "error",                    # Treat warnings as errors
    "ignore::DeprecationWarning:third_party.*",
]
```

## Coverage (Optional)

Only set up coverage when explicitly needed. Add `pytest-cov`:

```bash
uv add --group dev pytest-cov
```

Then extend your pytest config:

```toml
[tool.pytest.ini_options]
addopts = ["-q", "--strict-markers", "--strict-config", "--cov=myproject", "--cov-report=term-missing", "--cov-fail-under=80"]

[tool.coverage.run]
branch = true
source = ["src/myproject"]
omit = [
    "*/__main__.py",
    "*/conftest.py",
]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "if TYPE_CHECKING:",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
    "@abstractmethod",
]
fail_under = 80
show_missing = true
```

## Project Structure

```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       └── core.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py          # Shared fixtures
│   ├── test_core.py
│   └── integration/
│       └── test_api.py
└── pyproject.toml
```

## Running Tests

```bash
# Run all tests
uv run pytest

# Run with verbose output
uv run pytest -v

# Run specific file
uv run pytest tests/test_core.py

# Run specific test
uv run pytest tests/test_core.py::test_function_name

# Run tests matching pattern
uv run pytest -k "test_parse"

# Run marked tests
uv run pytest -m "not slow"

# Stop on first failure
uv run pytest -x

# Run last failed
uv run pytest --lf
```

## Coverage Commands

```bash
# Run with coverage
uv run pytest --cov=myproject

# Generate HTML report
uv run pytest --cov=myproject --cov-report=html
open htmlcov/index.html

# Coverage without running tests (use existing data)
uv run coverage report
uv run coverage html
```

## Writing Tests

### Basic Test

```python
# tests/test_core.py
from myproject.core import add_numbers

def test_add_numbers():
    assert add_numbers(2, 3) == 5

def test_add_negative():
    assert add_numbers(-1, 1) == 0
```

### Using Fixtures

```python
# tests/conftest.py
import pytest
from myproject.db import Database

@pytest.fixture
def db():
    """Provide a test database."""
    database = Database(":memory:")
    database.init()
    yield database
    database.close()

@pytest.fixture
def sample_data(db):
    """Populate database with sample data."""
    db.insert({"name": "test"})
    return db
```

```python
# tests/test_db.py
def test_query(sample_data):
    result = sample_data.query("test")
    assert result is not None
```

### Parametrized Tests

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    ("hello", 5),
    ("", 0),
    ("test", 4),
])
def test_string_length(input, expected):
    assert len(input) == expected
```

### Testing Exceptions

```python
import pytest
from myproject.core import divide

def test_divide_by_zero():
    with pytest.raises(ZeroDivisionError):
        divide(1, 0)

def test_divide_by_zero_message():
    with pytest.raises(ZeroDivisionError, match="division by zero"):
        divide(1, 0)
```

### Async Tests

```bash
uv add --group test pytest-asyncio
```

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await fetch_data()
    assert result is not None
```

## Property-Based Testing with Hypothesis

```bash
uv add --group test hypothesis
```

```python
from hypothesis import given, strategies as st
from myproject.core import reverse_string

@given(st.text())
def test_reverse_is_reversible(s):
    assert reverse_string(reverse_string(s)) == s

@given(st.integers(), st.integers())
def test_add_commutative(a, b):
    assert add(a, b) == add(b, a)
```

## Markers

```python
import pytest

@pytest.mark.slow
def test_slow_operation():
    # Long running test
    pass

@pytest.mark.integration
def test_api_call():
    # Requires external service
    pass

@pytest.mark.skip(reason="Not implemented yet")
def test_future_feature():
    pass

@pytest.mark.skipif(sys.platform == "win32", reason="Unix only")
def test_unix_feature():
    pass
```

## CI Configuration

```yaml
# GitHub Actions
- name: Checkout
  uses: actions/checkout@<sha>  # <latest> https://github.com/actions/checkout/releases

- name: Install dependencies
  run: uv sync --locked --all-groups

- name: Run tests
  run: uv run pytest
```

## Makefile Target

Add optional coverage targets only after installing `pytest-cov`:

```makefile
.PHONY: test test-cov test-fast

test: ## Run tests
	uv run pytest

test-cov: ## Run tests with HTML coverage report
	uv run pytest --cov-report=html
	open htmlcov/index.html

test-fast: ## Run tests quickly, stop on first failure
	uv run pytest -x -q
```
