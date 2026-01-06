---
description: Create implementation plan from definition and research. Outputs plan.md and TODO.md.
allowed-tools: Read, Write, Glob
---

## Task

Create an implementation plan for an already-defined and researched feature. This is Phase 3 of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned `work_dir` for all file operations.

## Prerequisites

This command requires an active work item with:
- `{work_dir}/{slug}/definition.md` - Created by `/workflow:1:define`
- `{work_dir}/{slug}/research.md` - Created by `/workflow:2:research`

If either is missing, stop and tell the user which step to run first.

## Process

### 1. Locate Work Artifacts

Find the definition and research files for the current work item.

### 2. Read Both Artifacts

Read and understand:
- **Definition**: Goals, non-goals, constraints, acceptance criteria
- **Research**: Affected files, patterns to follow, dependencies, risks

### 3. Create Plan

Use the `plan` skill to generate:
- `plan.md` - High-level approach and rationale
- `TODO.md` - Ordered checklist with phases and tasks

### 4. Write Outputs

Write both files to `{work_dir}/{slug}/`.

### 5. Summarize for User

Present:
- Number of phases
- High-level phase overview
- Any risks or concerns identified
- Confirm ready to begin implementation

## Rules

- Requires both definition and research before planning
- Follow patterns and conventions from research
- Stay within scope defined in definition
- Order tasks for incremental, testable progress
- Include checkpoints between phases
- Reference specific files from research in tasks
