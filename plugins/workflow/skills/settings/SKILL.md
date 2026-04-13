---
name: settings
description: Resolve workflow path configuration. Use when any workflow command needs to determine output paths. Checks for user overrides in .claude/workflow.local.md and falls back to defaults.
---

# Workflow Settings

Resolve path configuration for workflow commands by checking for user overrides and falling back to defaults.

## Purpose

Provides centralized path configuration for all workflow commands, supporting user customization while maintaining sensible defaults.

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

## Templates

### Display Template

```markdown
## Workflow Configuration

| Setting | Value | Source |
|---------|-------|--------|
| work_dir | {value} | {default|override} |
| learnings_dir | {value} | {default|override} |
| agents_dir | {value} | {default|override} |

**Override file:** {exists|not found}
```

### Override File Format

`.claude/workflow.local.md`:

```markdown
# Workflow Settings

Local overrides for workflow plugin paths.

## Paths
- work_dir: {selected}
- learnings_dir: {selected}
- agents_dir: {selected}
```

### Confirmation Template

```markdown
## Settings Saved

Configuration written to `.claude/workflow.local.md`

| Setting | Value |
|---------|-------|
| work_dir | {value} |
| learnings_dir | {value} |
| agents_dir | {value} |

These paths will be used by all workflow commands.

To reset to defaults, delete `.claude/workflow.local.md` or run `/workflow:0:settings` and select "Reset to defaults".
```

## Path Options

When customizing, offer these options per path:

**work_dir:**
- `.docs/work` (default)
- `docs/work`
- `.workflow`
- Custom path

**learnings_dir:**
- `.docs/learnings` (default)
- `docs/learnings`
- Custom path

**agents_dir:**
- `.claude/agents` (default)
- `agents/`
- Custom path

## Customization Flow

1. **Ask initial question:** "Would you like to customize workflow paths?"
   - Options: Keep current settings | Customize paths | Reset to defaults (if overrides exist)

2. **If customizing:** For each path, ask with options listed above

3. **After customization:** Write override file using template above

4. **Reset to defaults:** Delete `.claude/workflow.local.md` and confirm

## Usage in Commands

Commands should invoke this skill at the start:

```markdown
## Setup

Invoke the `settings` skill to resolve paths. Use the returned values for all file operations.
```

This ensures consistent path resolution across all workflow commands.
