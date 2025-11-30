---
name: compound
description: Capture non-trivial learnings as searchable documentation in .docs/learnings/. Use when: (1) debugging revealed non-obvious behavior, (2) architectural decision was made with tradeoffs, (3) external API/library quirk was discovered, (4) workflow shortcut was found, (5) user explicitly requests /compound, (6) agent recognizes significant learning worth preserving. Do NOT use for trivial fixes, obvious solutions, or information in official docs.
---

# Compound Skill

Transform learnings into searchable, maintainable documentation.

## Output Location

```
.docs/learnings/
├── {domain}/
│   └── {concept}.md
└── cross-cutting/
    └── {concept}.md
```

## Process

### 1. Determine Domain

Identify the domain from the learning's context:
- Match to existing folders in `.docs/learnings/` if applicable
- Create new domain folder only if no existing domain fits
- Use `cross-cutting/` for learnings spanning multiple domains

Domain = broad category (auth, payments, api, database, etc.)

### 2. Determine Concept

Name the specific concept being documented:
- Use `kebab-case`
- Be specific: `stripe-webhook-signatures` not `webhooks`
- Searchable: someone looking for this should find it by name

### 3. Check Existing Docs

Before creating new file:
1. Glob `.docs/learnings/**/*.md` for related files
2. If exact concept exists → update existing file
3. If related concept exists → consider merging or cross-referencing
4. If no match → create new file

### 4. Generate Documentation

Use template from `template.md`. Required sections:
- Title (H1)
- Summary (blockquote, one line)
- Content (the actual learning)
- Related (optional, code paths or links)

### 5. Write File

```
.docs/learnings/{domain}/{concept}.md
```

Create domain folder if needed. Folders emerge organically — never pre-create empty folders.

## Template

See [template.md](template.md) for documentation format.

## Quality Criteria

Before documenting, verify:
- [ ] Learning was non-trivial to discover
- [ ] Not already covered by official documentation
- [ ] Likely to benefit future development
- [ ] Concrete and actionable

If any criterion fails → do not document.

## File Rules

- One concept per file
- Max ~150 lines (split if larger)
- Filename = searchable concept name
- No "misc" or "other" catch-all files
- kebab-case for all filenames

## Staleness Prevention

When documenting, include code references naturally in content:
```markdown
The webhook handler in `src/billing/stripe-webhooks.ts` requires...
```

These references enable future staleness detection via grep.

## Domain Examples

| Domain | Concepts |
|--------|----------|
| auth | oauth-flow, session-refresh, token-rotation |
| payments | stripe-webhooks, refund-edge-cases |
| api | rate-limiting, pagination-cursors |
| database | migration-rollbacks, index-strategies |
| cross-cutting | error-handling, logging-patterns |
