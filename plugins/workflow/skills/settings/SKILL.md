---
name: settings
description: Resolve workflow path configuration. Use when any workflow command needs to determine output paths. Checks for user overrides in .claude/workflow.local.md and falls back to defaults.
---

# Workflow Settings

Resolve path configuration for workflow commands by checking for user overrides and falling back to defaults.

## Resolution Process

### 1. Load Defaults

Read defaults from @config/paths.md:

| Key | Default |
|-----|---------|
| work_dir | `.docs/work` |
| learnings_dir | `.docs/learnings` |
| agents_dir | `.claude/agents` |
| settings_file | `.claude/workflow.local.md` |

### 2. Check for Override File

Look for `.claude/workflow.local.md` at the workspace root.

**If file exists:**
- Parse the `## Paths` section
- Extract any overrides in format `- key: value`
- Merge with defaults (overrides take precedence)

**If file doesn't exist:**
- Use defaults as-is
- Note: settings can be created via `/workflow:0:settings`

### 3. Return Resolved Paths

Provide the calling command with resolved paths:

```
work_dir: {resolved}
learnings_dir: {resolved}
agents_dir: {resolved}
```

## Override File Format

`.claude/workflow.local.md`:

```markdown
# Workflow Settings

## Paths
- work_dir: .docs/work
- learnings_dir: .docs/learnings
- agents_dir: .claude/agents
```

## Usage in Commands

Commands should invoke this skill at the start:

```markdown
## Setup

Invoke the `settings` skill to resolve paths. Use the returned values for all file operations.
```

This ensures consistent path resolution across all workflow commands.
