---
name: slash-command-builder
description: Create and optimize Claude Code slash commands. Use when: (1) user wants to create a new slash command, (2) reviewing/improving existing commands, (3) adding frontmatter or arguments to commands, (4) organizing command workflows. Helps with description writing, frontmatter options, bash execution patterns, argument handling, and security restrictions.
---

# Slash Command Builder

Create high-quality, discoverable slash commands for Claude Code.

## Command File Structure

```markdown
---
description: What it does + when to use it
argument-hint: [expected-args]
allowed-tools: Tool1, Tool2, Bash(cmd:*)
---

## Context (optional)

Current state: !`bash command`
Reference: @path/to/file

## Task

Instructions using $ARGUMENTS or $1, $2, etc.
```

## Locations

| Scope | Path | Shows as |
|-------|------|----------|
| Project | `.claude/commands/name.md` | (project) |
| User | `~/.claude/commands/name.md` | (user) |
| Namespaced | `.claude/commands/group/name.md` | (project:group) |

## Frontmatter Options

| Field | Purpose | Example |
|-------|---------|---------|
| `description` | Discovery + /help text | "Review PR for security issues" |
| `argument-hint` | Expected format | `[issue-id] [priority]` |
| `allowed-tools` | Restrict access | `Read, Grep, Bash(git:*)` |
| `model` | Override model | `claude-sonnet-4-5-20250929` |
| `disable-model-invocation` | Prevent auto-trigger | `true` |

## Argument Handling

```markdown
# All args as single string
Review: $ARGUMENTS

# Positional access
File: $1, Mode: $2
```

## Dynamic Context

**Bash execution** (output included):
```markdown
Branch: !`git branch --show-current`
Status: !`git status --short`
```

**File reference** (content included):
```markdown
Review this: @src/utils.js
```

## Writing Effective Descriptions

The `description` field is critical — Claude uses it to discover commands.

**Good:**
```yaml
description: Fix GitHub issue by analyzing, implementing solution, and preparing PR
```

**Bad:**
```yaml
description: helps with issues
```

Rules:
- State what AND when
- Include keywords Claude recognizes
- Under 100 characters
- Be specific, not vague

## Security: allowed-tools

Always restrict bash access to specific commands:

```yaml
# Good - specific
allowed-tools: Bash(git status:*), Bash(git commit:*), Read

# Bad - too broad
allowed-tools: Bash(*)
```

Common patterns:
- Git ops: `Bash(git:*)`
- GitHub CLI: `Bash(gh:*)`
- Read-only: `Read, Grep, Glob`
- No bash: omit or `allowed-tools: Read, Grep, Glob`

## Templates

See [templates.md](templates.md) for ready-to-use command templates.

## Quality Checklist

Before finalizing a command:

- [ ] Description is specific and discoverable
- [ ] `argument-hint` matches expected usage
- [ ] `allowed-tools` restricts to minimum necessary
- [ ] Bash commands are specific, not wildcard
- [ ] File name is kebab-case and descriptive
- [ ] Single responsibility (one purpose per command)
- [ ] Context section gathers relevant state
- [ ] Task section has clear instructions
