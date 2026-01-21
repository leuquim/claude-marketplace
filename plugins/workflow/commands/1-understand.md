---
description: Progressive feature understanding through intent clarification and codebase exploration.
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
---

## Task

Understand a feature or task before planning. This is Phase 1 of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned `work_dir` for all file operations.

## Process

### Step 1: Initial Clarification

Ask broad questions to understand intent before any codebase exploration.

See `understand` skill for clarification rules and starter questions.

### Step 2: Targeted Deep Exploration

Once intent is understood, launch parallel exploration agents using Task tool.

Dispatch THREE agents simultaneously:
1. **Explore agent** - Find affected files, patterns, architecture
2. **Vector-research agent** - Semantic search for related implementations
3. **Repo-analyst agent** - Search documentation and team learnings

See `understand` skill for agent prompt templates.

### Step 3: Present Key Findings

Summarize exploration findings briefly. See `understand` skill for findings template.

Wait for user confirmation or redirection before proceeding.

### Step 4: Progressive Refinement

Generate questions dynamically based on user responses and codebase findings.

See `understand` skill for refinement rules and stop signals.

### Step 5: Synthesize Artifacts

#### 5a. Generate Feature Slug

Create date-prefixed kebab-case slug. See `understand` skill for format.

#### 5b. Draft Definition

Present draft definition.md. See `understand` skill for template.

Ask: "Does this capture what we discussed? Anything to add or change?"

Refine based on feedback until user confirms.

#### 5c. Write Research Document

Write research.md with exploration findings. See `understand` skill for template.

#### 5d. Write Files

Write both artifacts to `{work_dir}/{slug}/`:
- `definition.md`
- `research.md`

Verify quality criteria from `understand` skill before writing.

## Next Step

Confirm completion and suggest: `/workflow:2:plan`
