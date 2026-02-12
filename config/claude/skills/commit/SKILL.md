---
name: commit
description: >
  Create atomic conventional commits from staged and unstaged changes. Use when the user asks to
  commit, create commits, or invokes /commit. Analyzes the diff, splits changes into logical atomic
  commits, and creates them using conventional commit format.
---

# Commit

Analyze the current diff and create atomic conventional commits.

## Workflow

1. Run `git diff` and `git diff --cached` and `git status` to see all changes
2. Run `git log --oneline -10` to match recent commit style
3. Classify each change (see Splitting Strategy)
4. Stage and commit each group separately, in dependency order

## Commit Format

```
type: description
```

- **Types**: feat, fix, docs, style, refactor, perf, test, build, ci, ops, chore
- Imperative mood, present tense: "Add feature" not "added feature"
- **Always capitalize the first word** of the description: `feat: Add` not `feat: add`
- Title under 72 characters
- No body by default — only add one if the change is truly non-obvious
- Use HEREDOC for the commit message:
  ```
  git commit -m "$(cat <<'EOF'
  type: description
  EOF
  )"
  ```

## Type Reference

- **feat**: New feature or significant addition
- **fix**: Bug fix
- **docs**: Documentation only
- **style**: Formatting, whitespace, semicolons — no behavior change
- **refactor**: Code restructuring — no behavior change, no new feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **build**: Build tools, dependencies, project version
- **ci**: CI configuration and scripts
- **ops**: Infrastructure, deployment, backup, recovery
- **chore**: Everything else that doesn't modify src or test files

## Splitting Strategy

Each commit should have a single purpose. Analyze the diff and group changes by concern:

1. **Separate refactors from behavior changes.** If a file has both structural cleanup and new
   behavior, split into a `refactor:` commit followed by a `feat:` or `fix:` commit.

2. **Test-first when fixing bugs.** When a diff includes both a test and a fix:
   - First commit: add the test that exposes the bug (it would fail before the fix)
   - Second commit: the fix itself (the test now passes)
   - This proves the test actually catches the bug.

3. **Group by logical concern, not by file.** Changes across multiple files that serve one purpose
   belong in one commit. Changes within one file that serve different purposes belong in separate
   commits.

4. **Dependency order.** Commit foundational changes before changes that depend on them (e.g.,
   add a utility before the feature that uses it).

5. **Be pragmatic.** Not every change set needs to be split. If changes are small and cohesive,
   a single commit is fine. Splitting is valuable when it aids comprehension, not as a ritual.

## Staging Specific Changes

When splitting a file across commits, use `git add -p` or stage specific files by name.
Never use `git add -A` or `git add .` — always stage specific files.
