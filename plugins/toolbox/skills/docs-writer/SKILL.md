---
name: docs-writer
description: |
  Write high-quality technical documentation with enforced scope boundaries and length limits.
  Use when: (1) creating README files, (2) writing feature/component documentation,
  (3) creating API references, (4) writing guides or tutorials, (5) generating changelogs,
  (6) user asks for documentation of any kind. Enforces single-purpose documents,
  hard length limits, imperative voice, and automatic anti-pattern correction.
---

# Documentation Writer

Write focused, scannable documentation. One document = one purpose.

## Core Rules

1. **State purpose first** - Opening line declares what this document covers
2. **Imperative voice** - "Run the command" not "You can run the command"
3. **Code over prose** - Show working examples, minimize explanation
4. **Hard limits** - Stop and suggest extraction when exceeded

## Document Types

Identify which type applies, then follow its template in [templates.md](references/templates.md).

| Type | Purpose | Max Lines | Trigger Split |
|------|---------|-----------|---------------|
| README | Project discovery, quick-start | 100 | Any deep-dive content |
| Feature Doc | Single feature explanation | 150 | Multiple features |
| API Reference | Endpoint/function specs | Per-item | Implementation details |
| Guide | Accomplish one task | 200 | Multiple goals |
| Changelog | Version history | Unlimited | N/A |

## Workflow

### Step 1: Determine Type

Match the request to a document type. If unclear, ask.

### Step 2: Apply Template

Load the template from [templates.md](references/templates.md). Follow structure exactly.

### Step 3: Write Content

Apply these constraints:

**Length:**
- Description: 1-3 sentences max
- Section: 15 lines max before suggesting extraction
- Code examples: 1-2 per section, prefer inline

**Structure:**
- Max heading depth: 3 levels (##, ###, ####)
- Lists: max 1 nesting level
- Tables: prefer over nested lists for options/parameters

**Voice:**
- Imperative: "Install the package" not "The package can be installed"
- Direct: "This handles X" not "This is designed to handle X"
- No hedging: Remove "might", "could possibly", "may want to"

### Step 4: Check Anti-Patterns

Scan output against [anti-patterns.md](references/anti-patterns.md). Rewrite violations.

### Step 5: Enforce Limits

If any limit is exceeded:

1. Stop writing immediately
2. Report which limit was exceeded
3. Propose document split:

```
SCOPE LIMIT: [limit description]

Split proposal:
- [current-doc.md] - Keep: [sections to retain]
- [new-doc.md] - Extract: [sections to move]

Proceed with split?
```

Wait for confirmation before continuing.

## Quick Reference

**Always include:**
- Purpose statement (first line)
- Working code example
- Links to related docs

**Never include:**
- Multiple tutorials in README
- Implementation details in API reference
- "Also" additions that expand scope
- Empty or placeholder sections

**Extraction triggers:**
- Section >15 lines
- >3 code examples in one section
- Prerequisites >5 items
- Any "and also" scope expansion
