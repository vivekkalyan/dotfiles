# Dependabot: Automated Dependency Updates

Dependabot is GitHub's native solution for managing dependency updates through automated pull requests.

## Benefits

- **Security**: Automatically patches known vulnerabilities
- **Currency**: Dependencies stay current without manual effort
- **Transparency**: PRs include changelog and compatibility info

## Setup

Create `.github/dependabot.yml`:

```yaml
version: 2
updates:
  - package-ecosystem: pip
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 7
    groups:
      dev:
        patterns: ["*"]
        update-types: ["minor", "patch"]
```

See [templates/dependabot.yml](../templates/dependabot.yml) for a complete configuration.

## Configuration Options

### Schedule

```yaml
schedule:
  interval: weekly  # daily, weekly, monthly
  day: monday       # For weekly
  time: "09:00"     # Optional specific time
  timezone: "UTC"   # Optional timezone
```

### Cooldown (Supply Chain Protection)

```yaml
cooldown:
  default-days: 7  # Wait 7 days before updating to new releases
```

**Why 7 days?** Attackers sometimes publish malicious versions of legitimate packages. A delay allows time for detection and removal before your project adopts them.

### Groups

Combine related updates into single PRs:

```yaml
groups:
  dev:
    patterns: ["ruff", "pytest*", "mypy"]
    update-types: ["minor", "patch"]

  production:
    patterns: ["*"]
    update-types: ["patch"]
    exclude-patterns: ["ruff", "pytest*", "mypy"]
```

### Ignore Rules

```yaml
ignore:
  - dependency-name: "some-package"
    versions: [">=2.0"]  # Ignore major version 2+

  - dependency-name: "other-package"
    update-types: ["version-update:semver-major"]
```

### Reviewers and Labels

```yaml
reviewers:
  - username
  - org/team-name

labels:
  - dependencies
  - automated
```

## Complete Example

```yaml
version: 2
updates:
  # Python dependencies
  - package-ecosystem: pip
    directory: /
    schedule:
      interval: weekly
      day: monday
    cooldown:
      default-days: 7
    groups:
      dev:
        patterns: ["ruff", "pytest*", "hypothesis"]
        update-types: ["minor", "patch"]
      production:
        patterns: ["*"]
        update-types: ["patch"]
    reviewers:
      - your-team
    labels:
      - dependencies

  # GitHub Actions
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
    cooldown:
      default-days: 7
    groups:
      actions:
        patterns: ["*"]
        update-types: ["minor", "patch"]
```

## Dependabot vs pip-audit

| Feature | Dependabot | pip-audit |
|---------|------------|-----------|
| **Scope** | All updates | Known CVEs only |
| **Timing** | Scheduled | On-demand/CI |
| **Output** | Pull requests | Alerts/failures |
| **Use case** | Ongoing maintenance | Security gate |

**Recommendation:** Use both. pip-audit in CI catches vulnerabilities immediately. Dependabot handles regular maintenance and creates PRs for review.

## References

- [GitHub Dependabot documentation](https://docs.github.com/en/code-security/dependabot/dependabot-version-updates/configuration-options-for-the-dependabot.yml-file)
