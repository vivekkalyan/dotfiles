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

.PHONY: help dev lint format test build

help: ## Show available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

dev: ## Sync all dependency groups
	uv sync --all-groups

lint: ## Run linting and type checks
	uv run ruff format --check && uv run ruff check && uv run ty check src/

format: ## Format code
	uv run ruff format .

test: ## Run test suite
	uv run pytest

build: ## Build the package
	uv build
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
