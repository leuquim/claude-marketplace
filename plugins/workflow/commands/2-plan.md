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

**When to use Task tool:**
- Research doesn't list specific files to modify
- Patterns section is vague or missing
- Need to understand dependencies better
- Similar implementations weren't found

Dispatch an Explore agent with specific questions about the gap.

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
- Order phases to enable incremental verification
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
- Each phase should be verifiable before moving to next

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
- Suggest next step: `/workflow:3:work` (executes in isolated git worktree)

## Rules

- Interactive — propose, confirm, refine
- One phase at a time — don't dump entire plan
- User picks approach — recommend but don't decide
- Reference research — tasks should mention specific files
- Stay in scope — no tasks outside definition boundaries
