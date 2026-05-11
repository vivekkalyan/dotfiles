---
name: python-repo-setup
description: Bootstrap a new Python repository from scratch in the current directory with git, uv, and modern dev tooling. Use when the user asks to create a new Python project, set up a new repo, or initialize a Python package from an empty directory.
---

# Python Repo Setup

Set up a new Python repository from scratch in the current directory. Execute the following three steps in order, committing after each.

## Step 1: Initialize git

Run the git `init-empty` alias. If the alias is not available, run the equivalent:

```bash
git init && git commit --allow-empty --allow-empty-message --message 'Initial Commit'
```

## Step 2: Create uv app

```bash
uv init --app --package .
```

Add a root `.gitignore` before committing, at minimum:

```gitignore
.venv/
.coverage
.pytest_cache/
.ruff_cache/
.ty/
__pycache__/
*.py[cod]
build/
dist/
*.egg-info/
```

Then commit all generated files and `.gitignore`:

```
chore: Create uv app with package layout
```

## Step 3: Configure dev tooling

Invoke the `modern-python` skill directly to configure ruff, ty, prek, and pytest. Apply these repo-setup constraints:

- Use project-managed dev dependencies: `uv add --group dev ruff ty pytest prek`.
- Keep `uv.lock` as the source of truth for tool versions; do not add coverage unless requested.
- Use local `uv run ...` hooks with `language: system`, and use `uv run prek ...` in Makefile, CI, and validation commands.

After the modern-python skill completes, commit all changes:

```
chore: Configure dev tooling (ruff/ty/prek/pytest)
```
