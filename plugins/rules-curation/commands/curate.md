---
description: Evaluate current context for memory rule curation. Use when knowledge should be captured in .claude/rules/ or existing memory rules need attention.
argument-hint: [action]
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(find:*)
---

## Task

Curate Claude Code memory rules in `.claude/rules/` based on current conversation context.

### If action provided (`$ARGUMENTS` is not empty):

Execute the specified action using the `curate` skill:
- `create` - Capture knowledge as a new rule
- `revise` - Update an existing rule
- `consolidate` - Merge overlapping rules
- `remove` - Delete obsolete rule

### If no action provided:

1. Scan conversation for curation opportunities
2. Check existing rules in `.claude/rules/`
3. Identify:
   - Knowledge worth capturing (patterns, constraints, gotchas)
   - Rules that contradict current practice
   - Rules with overlapping scope
   - Rules with orphaned paths
4. Present findings:
   - **If nothing found**: Respond "No curation needed based on current context."
   - **If opportunities found**: Use AskUserQuestion with options for each finding

### After user selection:

Use the `curate` skill to execute the selected curation actions.

## What qualifies for rule creation

- Patterns implemented multiple times
- Constraints discovered through debugging
- Gotchas that caused confusion or bugs
- Unwritten rules that were almost violated

## What doesn't qualify

- One-off implementations
- Universal patterns Claude already knows
- Pure style preferences without technical justification
- Information better suited for documentation (use compound skill instead)

## Rule vs Learning distinction

- **Rule** (this command): Prescriptive - "Do this when working here"
- **Learning** (compound): Descriptive - "We discovered this about the system"

If the knowledge is descriptive rather than prescriptive, suggest using `/compound` instead.

Action: $ARGUMENTS
