# Testing with pytest

## Setup

```bash
uv add --group test pytest pytest-cov hypothesis
```

## Configuration

Add to `pyproject.toml`:

```toml
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
    "raise NotImplementedError",
]
omit = ["*/__main__.py", "*/conftest.py"]
```

## Project Structure

```
myproject/
├── src/
│   └── myproject/
│       ├── __init__.py
│       └── core.py
├── tests/
│   ├── conftest.py
│   ├── test_core.py
│   └── integration/
│       └── test_api.py
└── pyproject.toml
```

## Running Tests

```bash
# Run all tests
uv run pytest

# Verbose output
uv run pytest -v

# Stop on first failure
uv run pytest -x

# Run last failed
uv run pytest --lf

# Run specific file
uv run pytest tests/test_core.py

# Run specific test
uv run pytest tests/test_core.py::test_function

# Run by marker
uv run pytest -m slow

# Run matching pattern
uv run pytest -k "test_user"

# Show print output
uv run pytest -s

# Generate HTML coverage report
uv run pytest --cov-report=html
```

## Test Patterns

### Basic Test

```python
def test_addition():
    assert 1 + 1 == 2
```

### Fixtures

```python
import pytest

@pytest.fixture
def sample_data():
    return {"key": "value"}

def test_with_fixture(sample_data):
    assert sample_data["key"] == "value"
```

### Fixture with Cleanup

```python
@pytest.fixture
def temp_file(tmp_path):
    file = tmp_path / "test.txt"
    file.write_text("content")
    yield file
    # Cleanup happens automatically with tmp_path
```

### Parametrized Tests

```python
import pytest

@pytest.mark.parametrize("input,expected", [
    (1, 2),
    (2, 4),
    (3, 6),
])
def test_double(input, expected):
    assert input * 2 == expected
```

### Exception Testing

```python
import pytest

def test_raises_error():
    with pytest.raises(ValueError, match="invalid"):
        raise ValueError("invalid input")
```

### Async Tests

```bash
uv add --group test pytest-asyncio
```

```python
import pytest

@pytest.mark.asyncio
async def test_async_function():
    result = await some_async_function()
    assert result == expected
```

### Property-Based Testing

```python
from hypothesis import given
from hypothesis import strategies as st

@given(st.integers(), st.integers())
def test_addition_commutative(a, b):
    assert a + b == b + a
```

## Markers

Define in `pyproject.toml`:

```toml
[tool.pytest.ini_options]
markers = [
    "slow: marks tests as slow",
    "integration: marks tests as integration tests",
]
```

Use in tests:

```python
import pytest

@pytest.mark.slow
def test_slow_operation():
    ...

@pytest.mark.integration
def test_database_connection():
    ...
```

Run by marker:

```bash
uv run pytest -m "not slow"
uv run pytest -m integration
```

## GitHub Actions

```yaml
- name: Run tests
  run: uv run pytest --cov-report=xml

- name: Upload coverage
  uses: codecov/codecov-action@v4
  with:
    files: coverage.xml
```

## Makefile Targets

```makefile
.PHONY: test test-cov test-fast

test:
	uv run pytest

test-cov:
	uv run pytest --cov-report=html
	open htmlcov/index.html

test-fast:
	uv run pytest -x --lf
```
