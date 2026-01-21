---
description: Execute implementation plan one phase at a time with chunked review.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

## Task

Execute an implementation plan phase by phase. This is the execution step of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned values for all file operations.

## Prerequisites

This command requires an active work item with:
- `{work_dir}/{slug}/definition.md`
- `{work_dir}/{slug}/research.md`
- `{work_dir}/{slug}/plan.md`
- `{work_dir}/{slug}/TODO.md`

If any are missing, tell the user which step to run first (`/workflow:1:understand` or `/workflow:2:plan`).

## Project Agents

Before starting work, check for project-specific agents:

```bash
# Check for {agents_dir}/*.md
```

If found, load them to guide implementation:
- Project agents provide stack-specific patterns and best practices
- Use their "Work Mode" guidance when implementing
- They complement (not replace) standard implementation practices

## Process

### 1. Locate Work Artifacts

Find the TODO.md for the current work item.

### 2. Find Current Phase

Read TODO.md and find the first phase with incomplete tasks (has `- [ ]`).

If all phases complete, proceed to "Work Complete" section.

### 3. Execute Phase

For the current phase:

1. **Announce**: Tell user which phase is starting
2. **Read context**: Review definition, research, and plan for relevant details
3. **Analyze and chunk**: Break phase tasks into logical review units (see Chunked Review Mode)
4. **Offer review mode**: Ask user how they want to proceed
5. **Execute**: Either chunked (interactive) or all at once
6. **Mark complete**: Update TODO.md to mark tasks as `- [x]` as you complete them
7. **Checkpoint**: Verify the phase checkpoint criteria

---

## Chunked Review Mode

Break implementation into logical units that leverage Claude Code's diff UI for incremental review.

### Phase Start: Offer Review Mode

Before executing edits, present chunk breakdown and ask user preference:

```
Starting Phase 2: Add permission middleware

I've analyzed this phase and broken it into 5 logical chunks:

1. Permission type definition (types/auth.ts)
2. Middleware implementation (middleware/permissions.ts)
3. Route integration (routes/api.ts)
4. Error handling (utils/errors.ts)
5. Config updates (config/permissions.ts)

Review each change interactively?
□ Yes, review each chunk
□ No, execute all at once
□ Skip this phase
```

Use AskUserQuestion to capture preference.

### Chunk Breakdown Principles

Group edits into **logical units** — related changes that make sense to review together:

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
Chunk 2/5: Middleware implementation

This adds checkPermission middleware that:
• Extracts permissions from JWT token
• Validates against required permissions for route
• Returns 403 if insufficient

Next: Route integration

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

[Make additional edit → new diff appears]

Added console.warn with user ID and attempted permission.

Approve this addition?
```

Iterate until user approves, then proceed to next chunk.

### Batch Approval

If user says "do the rest", "finish it", or "no more reviews":
- Switch to execute-all mode
- Complete remaining chunks without pausing
- Return to normal phase completion flow

---

### 4. Run Quality Checks

After completing the phase, run lightweight quality checks:

**Auto-detect and run:**
- `package.json` scripts: `lint`, `typecheck`, `check`
- `Makefile` targets: `lint`, `check`
- Language-specific:
  - JS/TS: `npx tsc --noEmit` (if tsconfig exists)
  - Python: `ruff check .` or `flake8`
  - Go: `go vet ./...`
  - Rust: `cargo check`

Only run checks that exist in the project. Skip if none found.

Report any issues found.

### 5. Pause for Review

After phase completion + quality checks:

1. Summarize what was done
2. Report any quality issues
3. Ask user: "Ready to continue to next phase, or want to review first?"

Do NOT auto-proceed to next phase.

### 6. Work Complete

When all phases in TODO.md are marked complete:

1. **Summarize**: List all completed phases and key changes made
2. **Verify**: Confirm all acceptance criteria from definition.md are met
3. **Present options**:
   - "Ready to commit these changes?"
   - "Want to review any phase again?"
   - "Need to make additional changes?"

Do NOT automatically commit, merge, or create PRs. Wait for user direction.

## Rules

### Guidelines
- Complete tasks in order
- Mark tasks done immediately after completing
- Run quality checks after each phase
- Pause between phases for user review
- Follow patterns from research
- Apply project agent guidance (if agents directory exists)
- **Always offer chunked review mode** at phase start
- In chunked mode: one logical unit at a time, explain after diff, wait for approval

### Avoid
- Writing tests (explicitly excluded)
- Skipping tasks or phases
- Auto-proceeding without user confirmation
- Making changes outside defined scope
- Committing without user request
- In chunked mode: making multiple unrelated edits before explaining
- Proceeding to next chunk without explicit approval

## Quality Check Discovery

```bash
# Check for package.json scripts
cat package.json | grep -E '"(lint|typecheck|check)"'

# Check for Makefile
test -f Makefile && grep -E '^(lint|check):' Makefile

# Check for tsconfig
test -f tsconfig.json && echo "TypeScript project"

# Check for pyproject.toml or setup.py
test -f pyproject.toml && echo "Python project"
```

## Phase Completion Template

After completing a phase, report:

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
