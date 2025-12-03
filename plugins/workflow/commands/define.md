---
description: Define a feature before implementation. Clarifies requirements, scope, and constraints. Creates .docs/work/yyyy_mm_dd_{slug}/definition.md.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
---

## Task

Define a feature or task before implementation. This is Phase 1 of the development workflow.

## Process

### 1. Understand the Request

Review the conversation to understand what the user wants to build or change.

If the request is ambiguous or missing critical information, use AskUserQuestion to clarify:
- What problem does this solve?
- Who is the user/consumer?
- What are the success criteria?
- Any known constraints or dependencies?

Do NOT proceed with vague requirements. Clarify first.

### 2. Generate Feature Slug

Create a date-prefixed kebab-case slug from the feature name:
- Format: `yyyy_mm_dd_{feature-name}` using today's date
- Feature name: Short but descriptive (2-4 words)
- Searchable and memorable
- Examples: `2025_12_03_user-auth-flow`, `2025_12_03_api-rate-limiting`, `2025_12_03_checkout-validation`

### 3. Check for Existing Work

Glob `.docs/work/*/definition.md` to see if this feature already has a definition.
- If exists: Ask user whether to update existing or create new
- If not: Proceed with creation

### 4. Write Definition

Create `.docs/work/{yyyy_mm_dd_slug}/definition.md` with:

```markdown
# {Feature Title}

> {One-line summary of what this feature does}

## Problem

{What problem does this solve? Why does it matter?}

## Goals

- {Specific, measurable outcome 1}
- {Specific, measurable outcome 2}

## Non-Goals (Out of Scope)

- {What this feature explicitly does NOT do}
- {Prevents scope creep}

## Constraints

- {Technical constraints}
- {Business constraints}
- {Timeline constraints if any}

## User Story

As a {user type}, I want {action} so that {benefit}.

## Acceptance Criteria

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Open Questions

- {Unresolved question 1}
- {Unresolved question 2}
```

### 5. Confirm with User

After writing, summarize what was defined and confirm it captures their intent.

## Quality Criteria

Before writing definition, verify:
- [ ] Problem is clearly stated
- [ ] Goals are specific and measurable
- [ ] Scope boundaries are explicit
- [ ] No implementation details (that's for /research and /plan)

## Rules

- Focus on what (outcomes), not how (implementation)
- One feature per definition
- Keep it concise — aim for <100 lines
- Non-goals are as important as goals
- If something is unclear, ask — don't assume
