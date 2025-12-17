---
name: curate
description: Keep Claude Code memory rules aligned with current understanding. Use when knowledge should be captured as a rule in .claude/rules/, or when existing memory rules no longer match reality.
---

# Memory Rules Curation

Maintain Claude Code memory rules in `.claude/rules/` as a living knowledge base that evolves with the codebase.

## Principles

- **Selectivity**: Not everything becomes a rule. Prefer fewer high-signal rules.
- **Weight matching**: Atomic for simple constraints, structured only when context is essential.
- **Active pruning**: Removing stale rules matters as much as adding new ones.

## Process

### 1. Assess Situation

Determine the curation action:

| Signal | Action |
|--------|--------|
| Knowledge worth preserving | Create |
| Rule contradicts practice | Revise |
| Rules overlap | Consolidate |
| Rule paths match no files | Update paths or Remove |

### 2. Check Existing Rules

```bash
find .claude/rules -name "*.md" -type f
```

Read relevant rules to avoid duplication or identify consolidation targets.

### 3. Determine Paths

Rules should have `paths:` frontmatter matching the code area they apply to.

```yaml
paths: src/api/**/*.ts        # API TypeScript files
paths: src/auth/**            # All auth files
paths: **/*.test.ts           # All test files
```

Rules without `paths:` load globally - use sparingly.

### 4. Select Template Weight

**Decision flow:**
1. Can the rule be stated in one sentence without losing meaning? → **Atomic**
2. Does it need a "because..." to be applied correctly? → **Light**
3. Does it have conditionals, exceptions, or multi-step requirements? → **Structured**

| Weight | Use When | Example |
|--------|----------|---------|
| **Atomic** | Self-explanatory, no rationale needed | `Always validate request body before processing.` |
| **Light** | Needs rationale to be applied correctly | `Use exponential backoff - rate limiter uses sliding window, not fixed reset.` |
| **Structured** | Multiple parts, exceptions, or context required | Token refresh sequencing with race condition explanation |

Templates: @templates/atomic.md (~20 tokens), @templates/light.md (~50 tokens), @templates/structured.md (~150 tokens)

Default to atomic. Escalate only when simpler form loses essential information.

### 5. Execute Action

**Create**: Write new rule file using appropriate template.

**Revise**: Edit existing rule to match current understanding.

**Consolidate**: Merge overlapping rules into one, delete redundant files.

**Remove**: Delete rule file when no longer applicable.

### 6. Verify

- Glob pattern matches intended files: `find . -path "<pattern>"`
- No contradiction with other rules in same path scope
- Rule reads clearly when loaded alongside others

## File Organization

```
.claude/rules/
├── global/           # No paths: filter, always loaded
├── api/              # paths: src/api/**
│   ├── rate-limiting.md
│   └── validation.md
├── auth/             # paths: src/auth/**
└── testing/          # paths: **/*.test.*
```

**Folder strategy:**
- Organize by code area, not by rule type
- Create new folder when 3+ rules share a code area
- Keep flat within domain folders - no deep nesting
- File naming: `{concept}.md` (e.g., `rate-limiting.md`, `token-refresh.md`)

**Folder vs `paths:` relationship:**
- Folder = human organization (browsing, maintenance)
- `paths:` = Claude filtering (what gets loaded)
- They often align but don't have to. A rule in `api/` folder could have `paths: src/**/*.ts` if it applies broadly.
