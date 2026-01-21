---
description: Execute implementation plan one phase at a time with chunked review.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

## Task

Execute an implementation plan phase by phase. This is the execution step of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned values for all file operations.

## Prerequisites

Requires an active work item with:
- `{work_dir}/{slug}/definition.md`
- `{work_dir}/{slug}/research.md`
- `{work_dir}/{slug}/plan.md`
- `{work_dir}/{slug}/TODO.md`

If missing, tell user which step to run first.

## Project Agents

Check for project-specific agents at `{agents_dir}/*.md`. If found, load them to guide implementation patterns.

## Process

### 1. Locate Work Artifacts

Find the TODO.md for the current work item.

### 2. Find Current Phase

Read TODO.md and find the first phase with incomplete tasks (`- [ ]`).

If all phases complete, proceed to "Work Complete" section.

### 3. Execute Phase

1. **Announce**: Tell user which phase is starting
2. **Read context**: Review definition, research, and plan for relevant details
3. **Analyze and chunk**: Break phase tasks into logical review units
4. **Offer review mode**: Ask user preference (see `work` skill for template)
5. **Execute**: Either chunked (interactive) or all at once
6. **Mark complete**: Update TODO.md to mark tasks as `- [x]`
7. **Checkpoint**: Verify the phase checkpoint criteria

See `work` skill for chunked review mode details.

### 4. Run Quality Checks

Run lightweight quality checks after completing the phase.

See `work` skill for auto-detection and language-specific checks.

### 5. Pause for Review

Present phase completion summary. See `work` skill for template.

Ask: "Ready to continue to next phase, or want to review first?"

Do NOT auto-proceed to next phase.

### 6. Work Complete

When all phases complete:

1. Summarize all completed phases
2. Verify acceptance criteria from definition.md
3. Present options (commit, review, additional changes)

See `work` skill for completion template.

Do NOT automatically commit, merge, or create PRs.

## Rules

See `work` skill for complete guidelines and avoid list.

Key points:
- Complete tasks in order
- Mark tasks done immediately
- Pause between phases
- Always offer chunked review mode
- Never commit without user request
