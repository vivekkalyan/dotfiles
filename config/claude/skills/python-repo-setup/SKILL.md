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

Then commit all generated files:

```
chore: Create uv app with package layout
```

## Step 3: Configure dev tooling

Invoke the `modern-python` skill (via `/modern-python`) to configure ruff, ty, prek, and pytest. Delegate all configuration choices to that skill.

After the modern-python skill completes, commit all changes:

```
chore: Configure dev tooling (ruff/ty/prek/pytest)
```
