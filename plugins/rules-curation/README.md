# Rules Curation Plugin

Autonomous curation of Claude Code memory rules in `.claude/rules/`.

## Overview

Memory rules guide Claude's behavior for specific code areas. This plugin helps maintain rules as a living knowledge base that evolves with your codebase - creating new rules when patterns emerge, revising rules when practices change, and removing rules that no longer apply.

## Commands

### `/audit`

Health check for existing rules. Identifies:
- Orphaned paths (rules matching no files)
- Stale rules (referencing removed code)
- Conflicting rules (overlapping scope)
- Coverage gaps (code areas without rules)

### `/curate [action]`

Create, revise, consolidate, or remove rules based on conversation context.

**Actions:**
- `create` - Capture knowledge as a new rule
- `revise` - Update an existing rule
- `consolidate` - Merge overlapping rules
- `remove` - Delete obsolete rule

Without an action, scans the conversation for curation opportunities.

## When to Use

**Create rules for:**
- Patterns implemented multiple times
- Constraints discovered through debugging
- Gotchas that caused confusion or bugs

**Don't create rules for:**
- One-off implementations
- Universal patterns Claude already knows
- Pure style preferences without technical justification

## Rule vs Learning

- **Rule** (this plugin): Prescriptive - "Do this when working here"
- **Learning** (`/compound`): Descriptive - "We discovered this about the system"

Use `/compound` for discoveries; use `/curate` for constraints.

## Rule Templates

| Weight | Tokens | Use When |
|--------|--------|----------|
| Atomic | ~20 | Self-explanatory, no rationale needed |
| Light | ~50 | Needs rationale to be applied correctly |
| Structured | ~150 | Multiple parts, exceptions, or context |

Default to atomic. Escalate only when simpler form loses essential information.
