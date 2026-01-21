---
description: Create implementation plan interactively. Proposes approaches, builds phases incrementally.
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
---

## Task

Create an implementation plan through interactive refinement. This is Phase 2 of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned `work_dir` for all file operations.

## Prerequisites

Requires an active work item with:
- `{work_dir}/{slug}/definition.md`
- `{work_dir}/{slug}/research.md`

If missing, tell user to run `/workflow:1:understand` first.

## Process

### Step 1: Load Context

Read definition.md and research.md for the work item.

If significant gaps exist, use Task tool to dispatch an Explore agent before proceeding. See `plan` skill for gap indicators.

### Step 2: Propose Approaches

Based on definition goals and research findings, propose 2-3 implementation approaches with pros/cons.

Recommend one and ask user to choose.

### Step 3: Build Phases Incrementally

For the chosen approach, build the plan phase by phase:

1. Propose phase with goal, tasks, and checkpoint
2. Wait for user confirmation or feedback
3. Refine if needed, proceed to next phase
4. Repeat until all phases defined

See `plan` skill for phase design principles.

### Step 4: Synthesize Artifacts

Write both files to `{work_dir}/{slug}/`:
- `plan.md` - See `plan` skill for template
- `TODO.md` - See `plan` skill for template

Verify quality criteria from `plan` skill before writing.

### Step 5: Summarize

Present:
- Number of phases
- High-level phase overview
- Any risks identified

## Next Step

Suggest: `/workflow:3:work`

## Rules

- Interactive: propose, confirm, refine
- One phase at a time (don't dump entire plan)
- User picks approach (recommend but don't decide)
- Reference research (tasks should mention specific files)
- Stay in scope (no tasks outside definition boundaries)
