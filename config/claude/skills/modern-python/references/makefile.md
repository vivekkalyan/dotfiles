# Makefile Template

Use this as the default Makefile pattern for modern Python projects.

Inspired by: https://tech.davis-hansson.com/p/make/

## Canonical Template

```makefile
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: help install install-hooks lint format typecheck hooks test

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: install-hooks ## Install all dependencies
	uv sync --all-groups

install-hooks: ## Install pre-commit hooks
	prek install

lint: ## Lint code with ruff
	uv run ruff check . --fix

format: ## Format code with ruff
	uv run ruff format .

typecheck: ## Type-check code with ty
	uv run ty check

hooks: ## Run pre-commit hooks
	prek run --all-files

test: ## Run tests
	uv run pytest
```

## Document Targets with `##`

Every user-facing target should include a short `##` description so `make` prints a useful command list:

```makefile
install: ## Install dependencies
	uv sync --all-groups

clean: ## Clean build artifacts
	rm -rf build dist .pytest_cache .ruff_cache
```

With `.DEFAULT_GOAL := help`, running `make` prints the documented targets.
