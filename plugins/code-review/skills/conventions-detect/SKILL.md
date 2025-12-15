---
name: conventions-detect
description: Detect code convention inconsistencies. Use for: naming patterns, file organization, import ordering, comment styles, error handling patterns. Learns from codebase patterns rather than enforcing external rules.
---

# Conventions Detection Skill

Identify inconsistencies with established codebase conventions.

## Approach

This skill detects **internal inconsistencies** - deviations from patterns established in the codebase itself, not external style guides. First learn the conventions, then flag deviations.

## Detection Process

### 1. Learn Conventions

Before flagging issues, identify established patterns:

**Naming:**
- File naming: PascalCase, camelCase, kebab-case?
- Class/component naming patterns
- Variable/function naming conventions

**Organization:**
- Directory structure patterns
- File grouping (by feature, by type)
- Import ordering conventions

**Patterns:**
- Error handling approach
- Logging patterns
- Comment styles

### 2. Detect Inconsistencies

Flag code that deviates from learned conventions:

**Naming Inconsistencies:**
- Files named differently than similar files
- Mixed naming styles in same directory
- Inconsistent case patterns

**Import Inconsistencies:**
- Different ordering than established
- Missing grouping (stdlib vs external vs internal)
- Inconsistent path styles (relative vs absolute)

**Pattern Inconsistencies:**
- Different error handling than similar code
- Different logging approach
- Inconsistent comment styles

## What NOT to Flag

- Intentional exceptions (documented or obvious reason)
- External dependencies with different conventions
- Generated code
- Legacy code marked for migration

## Output Format

```markdown
### [Severity] {Inconsistency Type}

**Location:** `file:line`
**Category:** {Naming|Organization|Imports|Patterns}

**Convention:** {established pattern from codebase}
**Deviation:** {what this code does differently}

**Examples of Convention:**
- `file1.js` - follows pattern
- `file2.js` - follows pattern

**Initial Severity:** Low
```

## Severity Guidelines

Convention issues are typically **Low** severity unless they:
- Cause confusion (Medium)
- Create maintenance burden (Medium)
- Indicate deeper structural issues (escalate to architecture)

## Key Principle

Learn before judging. Spend time understanding what conventions exist before flagging deviations. A codebase using camelCase files isn't wrong - it's just using camelCase. Only flag files that break that codebase's own conventions.
