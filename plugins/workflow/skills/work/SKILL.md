---
name: work
description: Execute implementation plans with chunked review mode. Provides templates, quality checks, and phase execution guidance.
---

# Work Skill

Execute implementation plans phase by phase with optional chunked review for incremental feedback.

## Purpose

Provides detailed guidance for executing implementation plans, including chunked review mode, quality checks, and phase completion templates.

## Chunked Review Mode

Break implementation into logical units that leverage Claude Code's diff UI for incremental review.

### Phase Start: Offer Review Mode

Before executing edits, present chunk breakdown and ask user preference:

```
Starting Phase {N}: {Phase Name}

I've analyzed this phase and broken it into {X} logical chunks:

1. {Chunk description} ({file})
2. {Chunk description} ({file})
3. {Chunk description} ({file})
...

Review each change interactively?
- Yes, review each chunk
- No, execute all at once
- Skip this phase
```

### Chunk Breakdown Principles

Group edits into **logical units** - related changes that make sense to review together:

**Good chunks:**
- "Add type definition" (single file, single concept)
- "Implement core function + helper" (2 files, tightly coupled)
- "Wire up route handlers" (multiple routes, single purpose)

**Bad chunks:**
- "Edit auth.ts" (file-based, not concept-based)
- "All middleware changes" (too broad, loses focus)
- "Line 45-67" (too granular, no context)

Each chunk should be:
- Reviewable in <2 minutes
- Self-contained enough to understand
- Small enough that rejection isn't costly

### Per-Chunk Execution

For each chunk in interactive mode:

**Step 1: Make the edit**

Execute the edit. Claude Code shows the diff in the UI.

**Step 2: Explain (after diff is visible)**

```
Chunk {X}/{Y}: {Chunk title}

This adds/changes/removes {brief description} that:
- {Bullet 1 - what changed}
- {Bullet 2 - why it changed}
- {Bullet 3 - how it works}

Next: {Next chunk description}

Approve / Questions / Changes?
```

Format:
- Chunk progress (X/Y)
- Brief title
- 2-4 bullet explanation of what changed and why
- What's coming next
- Prompt for response

**Step 3: Handle response**

| Response | Action |
|----------|--------|
| Approve (ok, next, approve, looks good) | Proceed to next chunk |
| Questions | Answer, then re-prompt for approval |
| Changes requested | Keep diff visible, make additional edits, show new diff, re-prompt |
| "Do the rest" | Switch to execute-all mode for remaining chunks |

### Handling Questions

```
User: "Why 403 instead of 401?"

Claude: "401 is for authentication failures (who are you?),
403 is for authorization (you're authenticated but not
allowed). Since the JWT is valid but permissions are
insufficient, 403 is more semantically correct.

Want me to change it, or keep as-is?"
```

Stay in discussion until user explicitly approves or requests changes.

### Handling Change Requests

```
User: "Add logging when permission check fails"

[Make additional edit -> new diff appears]

Added console.warn with user ID and attempted permission.

Approve this addition?
```

Iterate until user approves, then proceed to next chunk.

### Batch Approval

If user says "do the rest", "finish it", or "no more reviews":
- Switch to execute-all mode
- Complete remaining chunks without pausing
- Return to normal phase completion flow

## Quality Checks

### Auto-Detection

Run lightweight quality checks after completing each phase:

**Check for package.json scripts:**
```bash
cat package.json | grep -E '"(lint|typecheck|check)"'
```

**Check for Makefile:**
```bash
test -f Makefile && grep -E '^(lint|check):' Makefile
```

**Check for tsconfig:**
```bash
test -f tsconfig.json && echo "TypeScript project"
```

**Check for Python project:**
```bash
test -f pyproject.toml && echo "Python project"
```

### Language-Specific Checks

- **JS/TS**: `npx tsc --noEmit` (if tsconfig exists)
- **Python**: `ruff check .` or `flake8`
- **Go**: `go vet ./...`
- **Rust**: `cargo check`

Only run checks that exist in the project. Skip if none found.

## Templates

### Phase Completion Template

```
## Phase {N} Complete: {Phase Name}

**Tasks completed:**
- [x] {Task 1}
- [x] {Task 2}

**Checkpoint:** {Verification result}

**Quality checks:**
- {Check 1}: {pass/fail}
- {Check 2}: {pass/fail}

**Issues found:** {None / list issues}

Ready for next phase?
```

### Work Complete Template

When all phases complete:

1. **Summarize**: List all completed phases and key changes made
2. **Verify**: Confirm all acceptance criteria from definition.md are met
3. **Present options**:
   - "Ready to commit these changes?"
   - "Want to review any phase again?"
   - "Need to make additional changes?"

## Rules

### Guidelines

- Complete tasks in order
- Mark tasks done immediately after completing
- Run quality checks after each phase
- Pause between phases for user review
- Follow patterns from research
- Apply project agent guidance (if agents directory exists)
- Always offer chunked review mode at phase start
- In chunked mode: one logical unit at a time, explain after diff, wait for approval

### Avoid

- Writing tests (explicitly excluded)
- Skipping tasks or phases
- Auto-proceeding without user confirmation
- Making changes outside defined scope
- Committing without user request
- In chunked mode: making multiple unrelated edits before explaining
- Proceeding to next chunk without explicit approval

## Quality Criteria

Before marking phase complete:
- [ ] All phase tasks marked `[x]`
- [ ] Checkpoint criteria verified
- [ ] Quality checks pass (or issues documented)
- [ ] User has reviewed and approved
