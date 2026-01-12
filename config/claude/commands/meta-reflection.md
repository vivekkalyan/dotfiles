Analyze session history to identify recurring user patterns and generate CLAUDE.md entries, commands, and hooks.

## Phase 1: Extract Session Data

Run the extraction script to parse and chunk session transcripts:

```bash
claude-extract-sessions --output ./session-analysis
```

This will:
- Find sessions in `~/.claude/projects/<encoded-cwd>/`
- Parse JSONL files, extracting user/assistant messages with tool markers
- Chunk into files of max 100K characters
- Write `manifest.json` with metadata

If the script reports "No sessions found", stop and inform the user.

Read the manifest to understand what was extracted:
```bash
cat ./session-analysis/manifest.json
```

## Phase 2: Read Reference Files

Read existing configuration to compare patterns against. Check if each exists before reading:
1. `./CLAUDE.md` (project-level)
2. `~/.claude/CLAUDE.md` (user-level)
3. `.claude/settings.json` (project settings - check for hooks)
4. `~/.claude/settings.json` (user settings - check for hooks)

Store the content of these files to pass to analysis subagents.

## Phase 3: Parallel Analysis

For each chunk file listed in the manifest, spawn a Task subagent in parallel.

**For each chunk, use these parameters:**
- **Subagent type**: `general-purpose`
- **Model**: `haiku`

**Analysis prompt template** (replace placeholders):

```
You are analyzing Claude Code session transcripts to identify recurring user patterns.

EXISTING CLAUDE.MD CONTENT:
---
[INSERT: Content from ./CLAUDE.md and ~/.claude/CLAUDE.md, or "None found" if empty]
---

EXISTING HOOKS:
---
[INSERT: Hooks from settings.json files, or "None configured" if empty]
---

YOUR TASK:
1. Read the transcript file: ./session-analysis/chunk-NNN.txt
2. Identify patterns where the user repeatedly:
   - Gives similar instructions → could become CLAUDE.md entry
   - Requests multi-step workflows → could become custom command
   - Wants pre/post checks on actions → could become hook
   - Corrects Claude's behavior → high-impact pattern (error_prevention)

SCORING CRITERIA:
- Frequency: 2-3 occurrences = LOW, 4-7 = MEDIUM, 8+ = HIGH
- Recency: Check session timestamps - recent (< 7 days) = full weight
- Impact factors to detect:
  - time_savings: repetitive instructions the user gives often
  - error_prevention: user corrects Claude's mistakes or behavior
  - workflow_critical: pattern appears at task start/end
  - user_frustration: emphatic language (caps, "always", "never", "please", repeated requests)

OUTPUT:
Write your analysis to: ./session-analysis/chunk-NNN.analysis.md

Use this exact format for each pattern found (minimum 2 occurrences):

---
PATTERN: <descriptive name>
TYPE: claude-md | command | hook | behavioral
STATUS: NEW | EXISTING | CONFLICT
FREQUENCY: <count>
RECENCY: recent | moderate | old
IMPACT_FACTORS: <comma-separated from: time_savings, error_prevention, workflow_critical, user_frustration>
EVIDENCE:
- "<exact quote 1>"
- "<exact quote 2>"
- "<exact quote 3>"
DRAFT:
<ready-to-use implementation text for CLAUDE.md entry, command content, or hook description>
CONFLICT_WITH: <quote existing rule if STATUS=CONFLICT, otherwise omit this line>
---

If no patterns with 2+ occurrences found, write only: NO PATTERNS FOUND

Do not include any text outside this format.
```

Launch ALL chunk analysis subagents in a single message (parallel execution).

If any subagent fails, stop the pipeline and report which chunk failed.

## Phase 4: Aggregate Results

After all subagents complete, read all `./session-analysis/chunk-*.analysis.md` files.

Perform aggregation:

1. **Parse patterns**: Extract each pattern block (between --- markers)

2. **Merge duplicates**: Group patterns with similar PATTERN names
   - Sum FREQUENCY values
   - Use most recent RECENCY (recent > moderate > old)
   - Combine EVIDENCE lists (dedupe, keep max 5 best quotes)
   - Union IMPACT_FACTORS
   - Keep the most complete DRAFT

3. **Calculate confidence score** for each merged pattern:
   ```
   frequency_score = {LOW: 0.3, MEDIUM: 0.6, HIGH: 1.0}[frequency_level]
   recency_score = {recent: 1.0, moderate: 0.7, old: 0.4}[recency]
   impact_score = len(impact_factors) / 4

   confidence = (frequency_score * 0.4) + (recency_score * 0.3) + (impact_score * 0.3)

   confidence_level = HIGH if confidence >= 0.7 else MEDIUM if confidence >= 0.4 else LOW
   ```

4. **Check for conflicts**: Compare each pattern's DRAFT against existing CLAUDE.md content
   - Mark as CONFLICT if it contradicts an existing rule
   - Mark as EXISTING if substantially similar content already exists

5. **Sort**: Order patterns by confidence score (descending)

6. **Write summary**: Save to `./session-analysis/SUMMARY.md`

## Phase 5: Interactive Approval

Present patterns to the user in priority order (highest confidence first) using AskUserQuestion.

For each pattern, create a question with:
- Header: Pattern type (e.g., "CLAUDE.md", "Command", "Hook")
- Question text showing:
  - Pattern name
  - Confidence level and breakdown
  - Impact factors
  - Evidence quotes (2-3 best)
  - Draft implementation
- Options: Approve, Reject, Skip

For approved patterns, ask a follow-up about scope:
- For CLAUDE.md entries: "Project-level (./CLAUDE.md)" vs "User-level (~/.claude/CLAUDE.md)"
- For commands: "Project (.claude/commands/)" vs "User (~/.claude/commands/)"
- For hooks: Show the suggested configuration, ask for confirmation before implementing

## Phase 6: Auto-Apply Approved Patterns

For each approved pattern:

**CLAUDE.md entries:**
1. Read the target file (create if doesn't exist)
2. Check for duplicate content (skip if already present)
3. Append the new entry under a clear section header
4. Report what was added and where

**Commands:**
1. Determine filename from pattern name (kebab-case)
2. Write to chosen location (.claude/commands/ or ~/.claude/commands/)
3. Report the new command path

**Hooks:**
1. Display the suggested hook configuration
2. Explain what it would do and when it triggers
3. Only modify settings.json after explicit user confirmation

## Phase 7: Display Summary

Show final statistics:

```
=== Meta-Reflection Complete ===
Sessions analyzed: [from manifest.total_sessions]
Chunks processed: [from manifest.total_chunks]
Patterns found:
  - CLAUDE.md entries: N (X new, Y existing)
  - Custom commands: N (X new)
  - Hooks: N (X new)
  - Behavioral: N
Approved and applied: N

Output saved to: ./session-analysis/
```

## Conflict Section

If any patterns have STATUS=CONFLICT, present them separately:

```
=== Conflicts with Existing Rules ===

Pattern: [name]
Your current rule: "[existing text]"
But you often said: "[evidence quote]" (N times)
Consider: Is the rule too strict, or were these exceptions?
```

## Error Handling

- **Extraction fails**: Report the error from claude-extract-sessions
- **No sessions**: "No session data found for this project"
- **Subagent fails**: Abort immediately, report which chunk failed
- **No patterns found**: "No recurring patterns detected in N sessions"
- **All patterns rejected**: "No patterns approved for implementation"
