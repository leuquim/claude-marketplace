---
description: Audit Claude Code memory rules for health - orphaned paths, staleness, conflicts, and coverage gaps.
allowed-tools: Read, Glob, Grep, Bash(find:*)
---

## Task

Perform comprehensive health check of Claude Code memory rules in `.claude/rules/`.

## Audit Checklist

### 1. Path Validation

For each rule with `paths:` frontmatter:
- Glob the pattern against actual file structure
- Flag rules where pattern matches zero files
- Suggest updated paths if files appear to have moved

### 2. Staleness Detection

For each rule:
- Check if any code references mentioned still exist
- Flag rules that reference removed/renamed files
- Identify rules not matching any recently modified files

### 3. Conflict Detection

Across all rules:
- Find rules with overlapping path patterns
- Check for contradictory instructions in same scope
- Flag potential conflicts for review

### 4. Coverage Analysis

- Identify directories with significant code but no rules
- Note areas with high churn (frequent changes) but no guidance
- Suggest areas that may benefit from rules

## Output Format

Provide summary:

```
Rules Audit Summary
==================

Total rules: X
Healthy: X
Issues found: X

Path Issues:
- [rule-file]: Pattern matches no files

Potential Staleness:
- [rule-file]: References [missing-file]

Conflicts:
- [rule-a] and [rule-b]: Overlapping scope, check for contradiction

Coverage Gaps:
- src/payments/: No rules, high file count
```

For each issue, propose specific fix using the `curate` skill.
