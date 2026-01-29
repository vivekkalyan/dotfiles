# Security Setup

Configure security tooling for Python projects using pre-commit hooks and CI auditing.

## Quick Setup

```bash
# Install prek (pre-commit runner)
brew install prek

# Or via cargo
cargo install prek

# Install hooks
prek install

# Set up secret detection baseline
detect-secrets scan > .secrets.baseline

# Audit GitHub Actions
actionlint
zizmor .github/workflows/
```

## Security Tools Overview

| Tool | Purpose | Integration |
|------|---------|-------------|
| shellcheck | Shell script validation | Pre-commit hook |
| detect-secrets | Prevent credential commits | Pre-commit hook |
| actionlint | GitHub Actions syntax | Pre-commit hook |
| zizmor | Actions security audit | Pre-commit hook |
| pip-audit | Dependency CVE scanning | CI |
| Dependabot | Automated updates | GitHub native |

## Pre-commit Configuration

See [templates/pre-commit-config.yaml](../templates/pre-commit-config.yaml) for a complete configuration.

### shellcheck

Validates shell scripts for errors and quoting issues:

```yaml
- repo: https://github.com/shellcheck-py/shellcheck-py
  rev: v0.10.0.1
  hooks:
    - id: shellcheck
      args: [--severity=error]
```

### detect-secrets

Prevents accidental credential commits:

```yaml
- repo: https://github.com/Yelp/detect-secrets
  rev: v1.5.0
  hooks:
    - id: detect-secrets
      args: [--baseline, .secrets.baseline]
```

Initialize baseline before first commit:

```bash
detect-secrets scan > .secrets.baseline
```

Handle false positives:

```bash
# Audit and mark false positives
detect-secrets audit .secrets.baseline

# Update baseline after marking
detect-secrets scan --baseline .secrets.baseline > .secrets.baseline.tmp
mv .secrets.baseline.tmp .secrets.baseline
```

### actionlint

Validates GitHub Actions workflow syntax:

```yaml
- repo: https://github.com/rhysd/actionlint
  rev: v1.7.4
  hooks:
    - id: actionlint
```

### zizmor

Audits GitHub Actions for security issues:

```yaml
- repo: https://github.com/woodruffw/zizmor
  rev: v1.0.0
  hooks:
    - id: zizmor
      args: [--persona=auditor, --min-confidence=medium]
```

Common findings:
- Excessive permissions on workflows
- Unpinned action versions
- Expression injection risks

## Dependency Auditing

### pip-audit

Scans dependencies against the Python Advisory Database:

```bash
# Install
uv tool install pip-audit

# Run audit
pip-audit --require-hashes -r requirements.txt

# Or with uv
uv run pip-audit
```

In CI:

```yaml
- name: Audit dependencies
  run: |
    uv tool install pip-audit
    pip-audit --require-hashes -r requirements.txt
```

### Dependabot

Automatically creates PRs for outdated packages. See [dependabot.md](dependabot.md) for configuration.

Key features:
- Weekly update checks
- 7-day cooldown for new releases (supply chain protection)
- Grouped PRs to reduce noise

## pip-audit vs Dependabot

| Feature | pip-audit | Dependabot |
|---------|-----------|------------|
| Scope | Known CVEs | All updates |
| Timing | On-demand/CI | Scheduled |
| Action | Alerts | Creates PRs |
| Use case | Security gate | Maintenance |

**Use both:** pip-audit catches vulnerabilities immediately in CI, while Dependabot handles ongoing maintenance.

## GitHub Actions Security

### Minimal Permissions

```yaml
permissions:
  contents: read  # Only what's needed
```

### Pin Actions to SHA

```yaml
- uses: actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683  # v4.2.2
```

### Avoid Expression Injection

```yaml
# Bad - vulnerable to injection
- run: echo "${{ github.event.issue.title }}"

# Good - use environment variable
- run: echo "$ISSUE_TITLE"
  env:
    ISSUE_TITLE: ${{ github.event.issue.title }}
```
