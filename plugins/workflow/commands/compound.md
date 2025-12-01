---
description: Capture conversation learnings as searchable docs. Use after solving non-trivial problems, discovering gotchas, or making architectural decisions.
argument-hint: [topic]
allowed-tools: Read, Write, Glob, Grep
---

## Task

Capture learnings from this conversation as documentation.

### If topic provided (`$ARGUMENTS` is not empty):
Document that specific topic using the `compound` skill.

### If no topic provided:
1. Scan this conversation for compound-worthy items
2. Filter strictly — include ONLY items that meet ALL criteria:
   - Required non-trivial effort to discover or solve
   - Not already in official documentation
   - Likely to recur or benefit future work
   - Concrete and actionable (not vague discussion)
3. Present results:
   - **If zero items qualify**: Respond "Nothing compound-worthy found in this conversation."
   - **If items found**: Use AskUserQuestion tool with multi-select, listing each candidate

### After user selection:
Use the `compound` skill to document each selected item.

## What qualifies (include)
- Debugging insights that took significant effort
- Non-obvious behavior or gotchas
- Architectural decisions with tradeoffs
- Workflow efficiency discoveries
- External API/library quirks
- Configuration that wasn't straightforward

## What doesn't qualify (exclude)
- Trivial fixes (typos, syntax errors)
- Information easily found in official docs
- One-off issues unlikely to recur
- Sensitive information (secrets, credentials)
- Vague discussions without concrete outcomes

## Quality rules
- Only include topics actually discussed in conversation
- Only include items that meet all criteria above
- If nothing qualifies, say so — do not force options

Topic: $ARGUMENTS
