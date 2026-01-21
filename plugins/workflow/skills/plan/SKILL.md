---
name: plan
description: Create implementation plan from definition and research artifacts. Outputs plan.md (approach) and TODO.md (ordered task checklist). Use after /workflow:1:understand is complete.
---

# Plan Skill

Transform definition and research into an actionable implementation plan.

## Path Configuration

Paths are resolved via the `settings` skill. See @config/paths.md for defaults.

## Input Requirements

Must have in `{work_dir}/{slug}/`:
- `definition.md` - Feature goals, scope, constraints
- `research.md` - Codebase findings, affected files, patterns

## Output

Create two files in `{work_dir}/{slug}/`:

### 1. `plan.md` - Implementation Approach

High-level strategy and rationale:

```markdown
# Plan: {Feature Title}

> Implementation plan for {slug}

## Approach

{Brief description of the implementation strategy}

## Key Decisions

- {Decision 1 and rationale}
- {Decision 2 and rationale}

## Phases Overview

1. **{Phase 1 name}** - {What this phase accomplishes}
2. **{Phase 2 name}** - {What this phase accomplishes}
3. **{Phase 3 name}** - {What this phase accomplishes}

## Dependencies

- {Phase 2 depends on Phase 1 because...}

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| {Risk} | {How to handle} |

## Out of Scope (Reminder)

- {From definition, what we're NOT doing}
```

### 2. `TODO.md` - Ordered Task Checklist

Use this exact template structure:

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

{One-line description of what this phase accomplishes}

- [ ] {Task 1.1}
- [ ] {Task 1.2}
- [ ] {Task 1.3}

**Checkpoint:** {How to verify this phase is complete}

---

## Phase 2: {Phase Name}

{One-line description of what this phase accomplishes}

- [ ] {Task 2.1}
- [ ] {Task 2.2}

**Checkpoint:** {How to verify this phase is complete}

---

## Phase 3: {Phase Name}

{One-line description of what this phase accomplishes}

- [ ] {Task 3.1}
- [ ] {Task 3.2}

**Checkpoint:** {How to verify this phase is complete}

---

## Final Checklist

- [ ] All acceptance criteria from definition met
- [ ] No regressions introduced
```

## Planning Guidelines

### Phase Design

- Each phase should produce working (if incomplete) code
- Order phases to enable incremental verification
- First phase: foundation/scaffolding
- Middle phases: core functionality
- Final phase: polish, edge cases, cleanup

### Task Granularity

- Feature-aspect level, not line-by-line
- Each task should take 5-30 minutes
- Group related changes together
- Split if task touches unrelated areas

### Task Ordering

Optimize for:
1. Dependencies (what must exist first)
2. Risk (tackle unknowns early)
3. Verifiability (enable verification as you go)
4. Momentum (quick wins build confidence)

### Good Task Examples

```markdown
- [ ] Create `UserPermissions` type in `types/auth.ts`
- [ ] Add permission check middleware in `middleware/auth.ts`
- [ ] Update `UserService` to include permissions in user fetch
- [ ] Add permission gate component for frontend routes
```

### Bad Task Examples

```markdown
- [ ] Implement permissions  # Too vague
- [ ] Add line 45 to auth.ts  # Too granular
- [ ] Do the auth stuff  # Not actionable
```

## Quality Criteria

Before finalizing plan, verify:
- [ ] All files from research are addressed
- [ ] Phases are ordered by dependencies
- [ ] Each phase has a verifiable checkpoint
- [ ] Tasks reference specific files/modules
- [ ] No tasks outside defined scope
- [ ] Acceptance criteria covered by final checklist
