---
description: Execute implementation plan one phase at a time. Uses git worktree for isolation, runs quality checks after each phase. Requires existing plan.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

## Task

Execute an implementation plan phase by phase. This is the execution step of the development workflow.

## Prerequisites

This command requires an active work item with:
- `.docs/work/{slug}/definition.md`
- `.docs/work/{slug}/research.md`
- `.docs/work/{slug}/plan.md`
- `.docs/work/{slug}/TODO.md`

If any are missing, tell the user which step to run first (`/define`, `/research`, or `/plan`).

## Process

### 1. Locate Work Artifacts

Find the TODO.md for the current work item.

### 2. Setup Worktree

Use the `git-worktree` skill:

1. Check if worktree exists for the slug:
   ```bash
   bash skills/git-worktree/scripts/worktree-manager.sh check {slug}
   ```

2. If `NOT_FOUND`, ask user to confirm creation using AskUserQuestion:
   - Worktree name (suggest: `{slug}`)
   - Base branch (suggest: default branch)

3. Create or reuse worktree:
   ```bash
   bash skills/git-worktree/scripts/worktree-manager.sh create {name} {base-branch}
   ```

4. Note the worktree path for all subsequent operations.

### 3. Find Current Phase

Read TODO.md and find the first phase with incomplete tasks (has `- [ ]`).

If all phases complete, congratulate user and suggest cleanup.

### 4. Execute Phase

For the current phase:

1. **Announce**: Tell user which phase is starting
2. **Read context**: Review definition, research, and plan for relevant details
3. **Execute tasks**: Complete each task in order
4. **Mark complete**: Update TODO.md to mark tasks as `- [x]` as you complete them
5. **Checkpoint**: Verify the phase checkpoint criteria

### 5. Run Quality Checks

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

### 6. Pause for Review

After phase completion + quality checks:

1. Summarize what was done
2. Report any quality issues
3. Ask user: "Ready to continue to next phase, or want to review first?"

Do NOT auto-proceed to next phase.

## Rules

### DO
- Work in the worktree context
- Complete tasks in order
- Mark tasks done immediately after completing
- Run quality checks after each phase
- Pause between phases for user review
- Follow patterns from research

### DO NOT
- Write tests (explicitly excluded)
- Skip tasks or phases
- Auto-proceed without user confirmation
- Make changes outside defined scope
- Commit without user request

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
