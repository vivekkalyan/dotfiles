Check the diff, and create commit(s)

## Best Practices for Commits

- **Conventional commit format**: Use the format `<type>: <description>` where type is one of:
  - feat: A new feature for the user or a significant addition to the codebase.
  - fix: A bug fix.
  - docs: Documentation only changes.
  - style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc).
  - refactor: A code change that neither fixes a bug nor adds a feature.
  - perf: A code change that improves performance.
  - test: Adding missing tests or correcting existing tests.
  - build: Changes that affect the build components like build tool, dependencies, project version.
  - chore: Other changes that don't modify src or test files.
- **Atomic commits**: Each commit should contain related changes that serve a single purpose
- **Split large changes**: If changes touch multiple concerns, split them into separate commits
- **Present tense, imperative mood**: Write commit messages as commands (e.g., "add feature" not "added feature")
- **Concise title**: Keep the title line under 72 characters. 
- **No body by default**: Use single-line commits. Only add a body if the change is truly non-obvious and requires
  explanation.
- When reviewing the diff, first classify each change as either:
  - behavior-preserving refactor (same external behavior, cleaner structure), or
  - behavior-changing (new behavior, bug fix, or changed contract).
- Prefer to:
  - put behavior-preserving refactors into `refactor:` commits, and
  - put behavior-changing edits into `feat:` or `fix:` commits.
- Avoid mixing large refactors and behavior changes in the same commit.
  - If a file has both, split into separate commits if reasonably possible.
