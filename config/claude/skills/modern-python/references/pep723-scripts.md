# PEP 723: Inline Script Metadata

PEP 723 allows embedding dependency information directly in Python scripts, eliminating the need for separate configuration files.

## When to Use

**Good for:**
- Single-file scripts with external dependencies
- Automation utilities
- Self-contained tools

**Use pyproject.toml instead for:**
- Multi-file projects
- Reusable libraries
- Complex dependency configurations

## Basic Structure

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "requests>=2.31",
#     "rich>=13.0",
# ]
# ///

import requests
from rich import print

response = requests.get("https://api.example.com/data")
print(response.json())
```

## Creating Scripts

```bash
# Initialize a new script
uv init --script myscript.py --python 3.12

# Add dependencies to existing script
uv add --script myscript.py requests rich
```

## Running Scripts

```bash
# Run with uv
uv run myscript.py

# Run directly (with shebang)
chmod +x myscript.py
./myscript.py

# Run with specific Python version
uv run --python 3.12 myscript.py
```

## Shebang Options

```python
# Basic
#!/usr/bin/env -S uv run --script

# Quiet mode (suppress uv output)
#!/usr/bin/env -S uv run --quiet --script

# Specific Python version
#!/usr/bin/env -S uv run --python 3.12 --script
```

## Examples

### Data Processing

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "pandas>=2.0",
#     "pyarrow>=14.0",
# ]
# ///

import pandas as pd

df = pd.read_parquet("data.parquet")
print(df.describe())
```

### Web Scraping

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "httpx>=0.27",
#     "beautifulsoup4>=4.12",
#     "lxml>=5.0",
# ]
# ///

import httpx
from bs4 import BeautifulSoup

response = httpx.get("https://example.com")
soup = BeautifulSoup(response.text, "lxml")
print(soup.title.string)
```

### CLI Tool

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "typer>=0.12",
#     "rich>=13.0",
# ]
# ///

import typer
from rich import print

app = typer.Typer()

@app.command()
def greet(name: str):
    print(f"[green]Hello, {name}![/green]")

if __name__ == "__main__":
    app()
```

### Async Script

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "httpx>=0.27",
#     "asyncio>=3.4",
# ]
# ///

import asyncio
import httpx

async def fetch_all(urls: list[str]) -> list[str]:
    async with httpx.AsyncClient() as client:
        tasks = [client.get(url) for url in urls]
        responses = await asyncio.gather(*tasks)
        return [r.text for r in responses]

if __name__ == "__main__":
    urls = ["https://example.com", "https://example.org"]
    results = asyncio.run(fetch_all(urls))
    for result in results:
        print(len(result))
```

## Best Practices

1. **Always specify requires-python** for reproducibility
2. **Use version ranges** like `>=2.31` instead of exact pins
3. **Keep scripts focused** on a single task
4. **Include type hints** for clarity
5. **Add docstrings** for documentation

## Limitations

PEP 723 does NOT support:
- Dependency groups
- Editable installs
- Local file dependencies
- Complex extras

For these needs, use a full `pyproject.toml` project.
