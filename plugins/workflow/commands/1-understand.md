---
description: Progressive feature understanding through intent clarification and codebase exploration.
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

**Agent prompts should include:**

For Explore agent:
- "Find files, patterns, and architecture related to [user's stated intent]"
- Focus on: affected modules, existing similar features, code organization

For Vector-research agent:
- "Search for implementations related to [user's stated intent]"
- Focus on: similar features, related utilities, relevant tests

For Repo-analyst agent:
- "Search documentation and team learnings for [user's stated intent]"
- Focus on: .docs/learnings/, README files, architectural decisions

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

## Quality Criteria

Before writing artifacts, verify:
- [ ] Problem is clearly stated (not vague)
- [ ] Goals are specific and measurable
- [ ] Scope boundaries are explicit (non-goals defined)
- [ ] No implementation details in definition (that's for planning)
- [ ] Research captures relevant codebase context

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

## Rules

- ONE question at a time — never overwhelm
- Explore AFTER understanding intent — avoid rabbit holes
- Dynamic questions — no hardcoded sequence
- Broad to specific — progressive refinement
- Multiple choice when codebase suggests options
- Small chunks — summaries <200 words, drafts <300 words
- Confirm before proceeding — validate understanding incrementally
