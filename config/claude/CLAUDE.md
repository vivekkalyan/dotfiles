# Global Agent Instructions

## Agent Notes

Use `.agent-notes/` in the repo root as your working scratchpad. This directory is globally gitignored and will never be committed.

**When to write notes:**
- After exploring an unfamiliar part of a codebase, save what you learned
- After completing a multi-step task, note what worked and what didn't
- When you discover project-specific conventions not documented elsewhere
- When a task is interrupted or paused, save progress and next steps

**Structure:**
- `.agent-notes/index.md` — list of active projects/tasks with one-line descriptions
- `.agent-notes/architecture.md` — codebase architecture, key files, patterns, conventions
- `.agent-notes/learnings.md` — gotchas, tips, things that didn't work, debugging insights
- `.agent-notes/<project-or-task>.md` — one file per project or task with context, progress, and next steps

**Tending the notes:**
- At the start of a session, read `index.md` to orient yourself
- After finishing a task, update its note file and mark it done in `index.md`
- Delete note files for completed or abandoned tasks — stale notes are worse than no notes
- Keep notes concise and useful for future sessions; update in place rather than appending endlessly
- Keep a concise worklog section in the notes to track what steps you have done.
