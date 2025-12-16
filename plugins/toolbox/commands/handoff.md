---
description: Generate handoff prompt for continuing work in new Claude session. Saves to ~/.claude/handoff/
allowed-tools: Bash, Write, AskUserQuestion
---

## Task

Generate a handoff document that enables a new Claude Code session to continue this work seamlessly. The handoff captures conversation context that would otherwise be lost.

## Why This Matters

When starting a new session:
- Git state persists (low value to capture extensively)
- File contents persist (can be re-read)
- Conversation context is lost (high value to capture)
- Decisions and rationale are lost (very high value - expensive to rediscover)
- Todo state is lost (must capture explicitly)

Prioritize capturing what the new session cannot recover on its own.

## Process

### 1. Get Handoff Name

Use AskUserQuestion: "Brief name for this handoff?"
- Suggest 2-3 names based on the conversation topic
- This becomes the filename slug

### 2. Extract Context

Review the conversation and extract these elements. Focus on what a new session needs to continue effectively.

| Element | What to Capture | Priority |
|---------|-----------------|----------|
| Goal | What the user is trying to accomplish (1-2 sentences) | Must |
| Completed Work | Files modified, problems solved, features implemented | Must |
| Key Decisions | Architecture choices, trade-offs, rejected alternatives with rationale | Must |
| Gotchas | Errors hit, workarounds applied, things that failed | Should |
| Open Questions | Unresolved issues, uncertainties | Should |
| Remaining Work | What's left to do, in priority order | Must |
| Critical Files | 3-5 files the new session should read first | Must |

### 3. Capture Claude Code State

| State | How to Capture |
|-------|----------------|
| Todo List | List all todos with status: completed [x], in_progress [~], pending [ ] |
| Working Directory | Current path |
| Git Branch | From `git branch --show-current` |
| Uncommitted Changes | From `git status --short` |

### 4. Generate and Save

Create the handoff document using the template below, then:

1. Create directory if needed: `mkdir -p ~/.claude/handoff`
2. Save to: `~/.claude/handoff/{yyyy-mm-dd-hhmm}-{slug}.md`
3. Confirm to user with the file path

## Output Template

```markdown
# Handoff: {Task Description}

## Goal
{1-2 sentences: what we're trying to accomplish}

## Completed
{Bulleted list of work done this session}

## Key Decisions
{Each decision with its rationale - capture the "why"}

## Gotchas
{Non-obvious issues discovered, workarounds, failed approaches}

## Files to Read First
- `{path}` - {reason}
- `{path}` - {reason}

## Remaining Work
{Prioritized list of what's left}

## Claude Code State

**Working Directory:** {path}

**Git:** {branch}, {clean|uncommitted changes summary}

**Todo List:**
Restore with TodoWrite:
- [x] {completed task}
- [~] {in_progress task} <- resume here
- [ ] {pending task}

---
*Handoff generated {date}*

**To continue:** Paste this into a new Claude Code session.
```

## Rules

- Write "None" for empty sections rather than omitting them
- Use absolute file paths throughout
- Keep sections concise - the handoff itself consumes context in the new session
- Capture rationale for decisions, not just the decisions themselves
- Format the todo list so the new session can restore it with TodoWrite immediately
