---
name: understand
description: Progressive feature understanding through intent clarification and codebase exploration. Provides templates, rules, and quality criteria for the understand phase.
---

# Understand Skill

Guide progressive feature understanding through intent clarification, codebase exploration, and artifact synthesis.

## Purpose

Transform vague requests into well-defined feature specifications through interactive refinement and codebase research.

## Templates

### Definition Template

`definition.md` (<300 words):

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

### Research Template

`research.md`:

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

### Findings Summary Template

Present exploration findings briefly (<200 words):

```
"I explored areas related to [user's intent]. Key findings:
- [Finding 1 - relevant code/pattern discovered]
- [Finding 2 - existing utilities or modules]
- [Finding 3 - permissions/access patterns]
- [Finding 4 - team learnings if any]

Does this cover the right areas, or should I explore something different?"
```

## Rules

### Clarification Phase

- Ask ONE question at a time
- Keep questions broad and open-ended initially
- 1-3 questions maximum before moving to exploration
- Do NOT explore the codebase yet
- Start with: "What problem are you trying to solve?" or "What do you want to accomplish?"
- Follow up with: "Who is affected?" / "What triggers this need?"

### Exploration Phase

- Explore AFTER understanding intent (avoid rabbit holes)
- Launch parallel agents for efficiency
- Synthesize findings into internal context (not shown to user yet)

### Refinement Phase

- Dynamic questions based on user responses and codebase findings
- Start broad, get progressively specific
- Each answer narrows the next question
- Prefer multiple choice when codebase suggests options
- Ask open-ended when truly novel territory
- One question at a time
- Summarize understanding after each answer

### Stop Signals

- User says "that's enough" or "let's move on"
- Problem is clearly stated
- Scope boundaries are defined (what's in, what's out)
- Success criteria can be articulated
- No major ambiguities remain

## Agent Prompts

### Explore Agent

```
Find files, patterns, and architecture related to [user's stated intent]
Focus on: affected modules, existing similar features, code organization
```

### Vector-Research Agent

```
Search for implementations related to [user's stated intent]
Focus on: similar features, related utilities
```

### Repo-Analyst Agent

```
Search documentation and team learnings for [user's stated intent]
Focus on: .docs/learnings/, README files, architectural decisions
```

## Quality Criteria

Before writing artifacts, verify:

- [ ] Problem is clearly stated (not vague)
- [ ] Goals are specific and measurable
- [ ] Scope boundaries are explicit (non-goals defined)
- [ ] No implementation details in definition (that's for planning)
- [ ] Research captures relevant codebase context

## Slug Format

Create a date-prefixed kebab-case slug:
- Format: `yyyy_mm_dd_{feature-name}` using today's date
- Example: `2026_01_21_data-export`

Check for existing work items with Glob `{work_dir}/*/definition.md`.

## Guidelines Summary

- ONE question at a time (never overwhelm)
- Explore AFTER understanding intent (avoid rabbit holes)
- Dynamic questions (no hardcoded sequence)
- Broad to specific (progressive refinement)
- Multiple choice when codebase suggests options
- Small chunks (summaries <200 words, drafts <300 words)
- Confirm before proceeding (validate understanding incrementally)
