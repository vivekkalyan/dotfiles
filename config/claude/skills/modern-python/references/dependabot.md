# Dependabot: Automated Dependency Updates

Dependabot is GitHub's native solution for managing dependency updates through automated pull requests.

## Benefits

- **Security**: Automatically patches known vulnerabilities
- **Currency**: Dependencies stay current without manual effort
- **Transparency**: PRs include changelog and compatibility info

## Setup

Copy [templates/dependabot.yml](../templates/dependabot.yml) to `.github/dependabot.yml`.

The template configures:
- Weekly updates for pip and GitHub Actions
- 7-day cooldown for newly released versions
- Grouped PRs to reduce noise

## Supply Chain Protection

A 7-day delay allows time for detection and removal of compromised packages before they enter your codebase.

## Configuration Options

### Schedule

```yaml
schedule:
  interval: weekly  # daily, weekly, monthly
  day: monday       # For weekly
  time: "09:00"     # Optional specific time
  timezone: "UTC"   # Optional timezone
```

### Cooldown

```yaml
cooldown:
  default-days: 7  # Wait 7 days before updating to new releases
```

### Groups

Combine related updates into single PRs:

```yaml
groups:
  dev-dependencies:
    dependency-type: development
    update-types: [minor, patch]
  production-dependencies:
    dependency-type: production
    update-types: [patch]
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
