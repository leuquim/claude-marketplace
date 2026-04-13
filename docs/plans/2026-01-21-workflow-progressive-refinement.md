# Workflow Progressive Refinement Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Restructure workflow plugin from 4 phases (Define, Research, Plan, Work) to 3 phases (Understand, Plan, Work) with progressive refinement and dynamic questioning.

**Architecture:** Merge Define and Research into a new "Understand" phase that interleaves intent clarification with targeted codebase exploration. Questions are generated dynamically (broad → specific) based on user answers and exploration findings. Plan phase becomes interactive with approach proposals and incremental phase building.

**Tech Stack:** Markdown command files, Claude Code skills

---

## Task 1: Create Understand Command

**Files:**
- Create: `plugins/workflow/commands/1-understand.md`

**Step 1: Write the understand command**

Create the new merged command that implements the 5-step flow:
1. Initial clarification (1-3 broad questions, no exploration)
2. Targeted deep exploration (parallel agents based on intent)
3. Present key findings (brief summary, confirm relevance)
4. Progressive refinement (dynamic questions, broad → specific)
5. Synthesize artifacts (definition.md + research.md)

```markdown
---
description: Understand a feature through progressive refinement. Clarifies intent, explores codebase, asks informed questions.
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
---

## Task

Understand a feature or task before planning. This is Phase 1 of the development workflow.

Combines requirement definition with codebase research through an interactive, progressive refinement process.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned `work_dir` for all file operations.

## Process

### Step 1: Initial Clarification

Before any codebase exploration, ask broad questions to understand intent:

- Start with: "What problem are you trying to solve?" or "What do you want to accomplish?"
- Follow up with: "Who is affected?" / "What triggers this need?"
- Goal: Understand enough to know WHERE to explore in the codebase

**Rules:**
- Ask ONE question at a time
- Keep questions broad and open-ended at this stage
- 1-3 questions maximum before moving to exploration
- Do NOT explore the codebase yet

### Step 2: Targeted Deep Exploration

Once intent is understood, launch parallel exploration agents:

Use the Task tool to dispatch THREE agents simultaneously:

1. **Explore agent** — Find affected files, patterns, architecture related to the user's intent
2. **Vector-research agent** — Semantic search for related implementations, similar features
3. **Repo-analyst agent** — Search documentation, team learnings, existing knowledge

Synthesize findings into internal context (not shown to user yet).

### Step 3: Present Key Findings

Summarize exploration findings briefly (<200 words):

```
"I explored areas related to [user's intent]. Key findings:
• [Finding 1 - relevant code/pattern discovered]
• [Finding 2 - existing utilities or modules]
• [Finding 3 - permissions/access patterns]
• [Finding 4 - team learnings if any]

Does this cover the right areas, or should I explore something different?"
```

Wait for user confirmation or redirection before proceeding.

### Step 4: Progressive Refinement

Generate questions dynamically based on:
- What the user has said so far
- What codebase exploration revealed
- What remains unclear or ambiguous

**Question generation principles:**
- Start broad, get progressively specific
- Each answer narrows the next question
- Prefer multiple choice when codebase suggests options (e.g., "Should we extend X or build new?")
- Ask open-ended when truly novel territory
- One question at a time
- Summarize understanding after each answer

**Continue until:**
- Problem is clearly stated
- Scope boundaries are defined (what's in, what's out)
- Success criteria can be articulated
- No major ambiguities remain

**Stop signals:**
- User says "that's enough" or "let's move on"
- AI judges understanding is sufficient to write definition

### Step 5: Synthesize Artifacts

#### 5a. Generate Feature Slug

Create a date-prefixed kebab-case slug:
- Format: `yyyy_mm_dd_{feature-name}` using today's date
- Example: `2026_01_21_data-export`

Check for existing work items with Glob `{work_dir}/*/definition.md`.

#### 5b. Draft Definition

Present draft definition.md (<300 words):

```markdown
# {Feature Title}

> {One-line summary}

## Problem

{What problem does this solve? Why does it matter?}

## Goals

- {Specific, measurable outcome 1}
- {Specific, measurable outcome 2}

## Non-Goals (Out of Scope)

- {What this feature explicitly does NOT do}

## Constraints

- {Technical constraints discovered during exploration}
- {Business/user constraints from conversation}

## User Story

As a {user type}, I want {action} so that {benefit}.

## Acceptance Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Open Questions

- {Any remaining uncertainties}
```

Ask: "Does this capture what we discussed? Anything to add or change?"

Refine based on feedback until user confirms.

#### 5c. Write Research Document

Write research.md with exploration findings:

```markdown
# Research: {Feature Title}

> Codebase exploration findings for {slug}

## Team Knowledge

{Relevant learnings from .docs/learnings/ if any}

## Affected Files

| File | Change Type | Purpose |
|------|-------------|---------|
| {path} | Create/Modify | {Why} |

## Existing Patterns

{Code patterns discovered that should be followed}

## Dependencies

{External dependencies, internal module dependencies}

## Similar Implementations

{Reference implementations found in codebase}

## Risks

| Risk | Impact | Notes |
|------|--------|-------|
| {Risk} | {High/Med/Low} | {Details} |
```

#### 5d. Write Files

Write both artifacts to `{work_dir}/{slug}/`:
- `definition.md`
- `research.md`

Confirm completion and suggest next step: `/workflow:2:plan`

## Quality Criteria

Before writing artifacts, verify:
- [ ] Problem is clearly stated (not vague)
- [ ] Goals are specific and measurable
- [ ] Scope boundaries are explicit (non-goals defined)
- [ ] No implementation details in definition (that's for planning)
- [ ] Research captures relevant codebase context

## Rules

- ONE question at a time — never overwhelm
- Explore AFTER understanding intent — avoid rabbit holes
- Dynamic questions — no hardcoded sequence
- Broad to specific — progressive refinement
- Multiple choice when codebase suggests options
- Small chunks — summaries <200 words, drafts <300 words
- Confirm before proceeding — validate understanding incrementally
```

**Step 2: Verify file was created**

Run: `cat plugins/workflow/commands/1-understand.md | head -20`
Expected: Shows frontmatter and first section

**Step 3: Commit**

```bash
git add plugins/workflow/commands/1-understand.md
git commit -m "feat(workflow): add understand command with progressive refinement"
```

---

## Task 2: Update Plan Command for Interactive Approach

**Files:**
- Modify: `plugins/workflow/commands/3-plan.md` → rename to `2-plan.md`

**Step 1: Write the updated plan command**

Update to support interactive approach building:
1. Load context (definition + research, explore further if gaps)
2. Propose 2-3 approaches with recommendation
3. Build phases incrementally with user confirmation
4. Synthesize plan.md + TODO.md

```markdown
---
description: Create implementation plan interactively. Proposes approaches, builds phases incrementally.
allowed-tools: Read, Write, Glob, Grep, Task, AskUserQuestion
---

## Task

Create an implementation plan through interactive refinement. This is Phase 2 of the development workflow.

## Setup

Invoke the `settings` skill to resolve paths. Use the returned `work_dir` for all file operations.

## Prerequisites

This command requires an active work item with:
- `{work_dir}/{slug}/definition.md` - Created by `/workflow:1:understand`
- `{work_dir}/{slug}/research.md` - Created by `/workflow:1:understand`

If either is missing, tell the user to run `/workflow:1:understand` first.

## Process

### Step 1: Load Context

Read definition.md and research.md for the work item.

If significant gaps are identified (e.g., affected files unclear, patterns not documented), use Task tool to explore further before proceeding.

### Step 2: Propose Approaches

Based on definition goals and research findings, propose 2-3 implementation approaches:

```
"Based on the definition and what I found in the codebase, I see these approaches:

A) [Approach name] — [Brief description]
   Pros: [advantages]
   Cons: [disadvantages]

B) [Approach name] — [Brief description]
   Pros: [advantages]
   Cons: [disadvantages]

C) [Approach name] — [Brief description]
   Pros: [advantages]
   Cons: [disadvantages]

I'd recommend [X] because [reasoning].

Which direction?"
```

Wait for user to pick or propose alternative.

### Step 3: Build Phases Incrementally

For the chosen approach, build the plan phase by phase:

**For each phase:**

1. Propose the phase:
   ```
   "Phase 1 would be: [Phase name]

   This phase accomplishes: [goal]

   Tasks:
   • [Task 1]
   • [Task 2]
   • [Task 3]

   Checkpoint: [How to verify completion]

   Does this make sense as the first phase?"
   ```

2. Wait for user confirmation or feedback

3. Refine if needed, then proceed to next phase

4. Repeat until all phases are defined

**Phase design principles:**
- Each phase produces working (if incomplete) code
- Order phases to enable incremental testing
- First phase: foundation/scaffolding
- Middle phases: core functionality
- Final phase: polish, edge cases, cleanup

### Step 4: Synthesize Artifacts

#### 4a. Write plan.md

```markdown
# Plan: {Feature Title}

> Implementation plan for {slug}

## Approach

{Brief description of chosen approach and why}

## Key Decisions

- {Decision 1 and rationale}
- {Decision 2 and rationale}

## Phases Overview

1. **{Phase 1 name}** — {What this phase accomplishes}
2. **{Phase 2 name}** — {What this phase accomplishes}
3. **{Phase 3 name}** — {What this phase accomplishes}

## Dependencies

- {Phase dependencies if any}

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| {Risk} | {How to handle} |

## Out of Scope (Reminder)

- {From definition, what we're NOT doing}
```

#### 4b. Write TODO.md

```markdown
# TODO: {Feature Title}

> Ordered implementation tasks for {slug}

## Development Rules

- Complete tasks in order (dependencies matter)
- Mark each task done immediately after completing: `- [x]`
- Do not skip ahead unless explicitly approved
- Each phase should be testable before moving to next
- Commit after completing each phase

---

## Phase 1: {Phase Name}

{One-line description}

- [ ] {Task 1.1}
- [ ] {Task 1.2}
- [ ] {Task 1.3}

**Checkpoint:** {Verification criteria}

---

## Phase 2: {Phase Name}

{One-line description}

- [ ] {Task 2.1}
- [ ] {Task 2.2}

**Checkpoint:** {Verification criteria}

---

[Continue for all phases]

---

## Final Checklist

- [ ] All acceptance criteria from definition met
- [ ] Tests passing
- [ ] No regressions introduced
```

#### 4c. Write Files

Write both to `{work_dir}/{slug}/`:
- `plan.md`
- `TODO.md`

### Step 5: Summarize

Present:
- Number of phases
- High-level phase overview
- Any risks identified
- Suggest next step: `/workflow:3:work`

## Rules

- Interactive — propose, confirm, refine
- One phase at a time — don't dump entire plan
- User picks approach — recommend but don't decide
- Reference research — tasks should mention specific files
- Stay in scope — no tasks outside definition boundaries
```

**Step 2: Rename file**

Run: `mv plugins/workflow/commands/3-plan.md plugins/workflow/commands/2-plan.md`

**Step 3: Verify**

Run: `ls plugins/workflow/commands/`
Expected: Shows `0-settings.md`, `1-understand.md`, `2-plan.md`, `4-work.md`

**Step 4: Commit**

```bash
git add plugins/workflow/commands/2-plan.md
git add plugins/workflow/commands/3-plan.md
git commit -m "feat(workflow): update plan command for interactive approach building"
```

---

## Task 3: Renumber Work Command

**Files:**
- Rename: `plugins/workflow/commands/4-work.md` → `3-work.md`
- Modify: Update internal references to phase numbers

**Step 1: Rename file**

Run: `mv plugins/workflow/commands/4-work.md plugins/workflow/commands/3-work.md`

**Step 2: Update references in the file**

Update any references to `/workflow:1:define`, `/workflow:2:research`, `/workflow:3:plan` to use new numbering:
- `/workflow:1:understand`
- `/workflow:2:plan`

**Step 3: Verify**

Run: `grep -n "workflow:" plugins/workflow/commands/3-work.md`
Expected: Shows updated references

**Step 4: Commit**

```bash
git add plugins/workflow/commands/3-work.md
git add plugins/workflow/commands/4-work.md
git commit -m "refactor(workflow): renumber work command from 4 to 3"
```

---

## Task 4: Delete Old Commands

**Files:**
- Delete: `plugins/workflow/commands/1-define.md`
- Delete: `plugins/workflow/commands/2-research.md`

**Step 1: Remove old files**

```bash
rm plugins/workflow/commands/1-define.md
rm plugins/workflow/commands/2-research.md
```

**Step 2: Verify**

Run: `ls plugins/workflow/commands/`
Expected: Shows only `0-settings.md`, `1-understand.md`, `2-plan.md`, `3-work.md`

**Step 3: Commit**

```bash
git add plugins/workflow/commands/1-define.md
git add plugins/workflow/commands/2-research.md
git commit -m "refactor(workflow): remove old define and research commands"
```

---

## Task 5: Update Plan Skill References

**Files:**
- Modify: `plugins/workflow/skills/plan/SKILL.md`

**Step 1: Update skill to reference new command structure**

Update the description and any references to use:
- `/workflow:1:understand` instead of `/workflow:1:define` and `/workflow:2:research`

Change line 3 from:
```
description: Create implementation plan from definition and research artifacts. Outputs plan.md (approach) and TODO.md (ordered task checklist). Use after /workflow:1:define and /workflow:2:research are complete.
```

To:
```
description: Create implementation plan from definition and research artifacts. Outputs plan.md (approach) and TODO.md (ordered task checklist). Use after /workflow:1:understand is complete.
```

**Step 2: Verify**

Run: `head -5 plugins/workflow/skills/plan/SKILL.md`
Expected: Shows updated description

**Step 3: Commit**

```bash
git add plugins/workflow/skills/plan/SKILL.md
git commit -m "docs(workflow): update plan skill references to new command structure"
```

---

## Task 6: Update Plugin Manifest

**Files:**
- Modify: `plugins/workflow/.claude-plugin/plugin.json`

**Step 1: Update version and description**

Change from:
```json
{
  "name": "workflow",
  "version": "1.1.0",
  "description": "Complete development workflow: define requirements, research codebase, plan implementation, execute with isolation, review with specialized agents, capture learnings",
  ...
}
```

To:
```json
{
  "name": "workflow",
  "version": "2.0.0",
  "description": "Progressive development workflow: understand (clarify + explore), plan (interactive approach building), work (execute with isolation)",
  ...
}
```

Version bump to 2.0.0 because this is a breaking change (command structure changed).

**Step 2: Verify**

Run: `cat plugins/workflow/.claude-plugin/plugin.json`
Expected: Shows version 2.0.0 and updated description

**Step 3: Commit**

```bash
git add plugins/workflow/.claude-plugin/plugin.json
git commit -m "chore(workflow): bump to v2.0.0 for progressive refinement restructure"
```

---

## Final Checklist

- [ ] New understand command created with 5-step flow
- [ ] Plan command updated for interactive approach building
- [ ] Work command renumbered and references updated
- [ ] Old define and research commands deleted
- [ ] Plan skill references updated
- [ ] Plugin manifest version bumped to 2.0.0
- [ ] All commits made with descriptive messages
