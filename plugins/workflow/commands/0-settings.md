---
description: View and configure workflow paths. Shows current settings and offers customization.
allowed-tools: Read, Write, Glob, AskUserQuestion
---

## Task

Display current workflow configuration and offer to customize paths.

## Process

### 1. Load Current Configuration

Invoke the `settings` skill to resolve current paths.

### 2. Check Override Status

```bash
# Check if user override file exists
```

Look for `.claude/workflow.local.md` at workspace root.

### 3. Display Current Settings

Present current configuration:

```markdown
## Workflow Configuration

| Setting | Value | Source |
|---------|-------|--------|
| work_dir | {value} | {default|override} |
| learnings_dir | {value} | {default|override} |
| agents_dir | {value} | {default|override} |

**Override file:** {exists|not found}
```

### 4. Offer Customization

Use AskUserQuestion:

**Question:** "Would you like to customize workflow paths?"

**Options:**
- Keep current settings
- Customize paths
- Reset to defaults (only if overrides exist)

### 5. If Customizing

For each path, use AskUserQuestion:

**Question:** "Work directory for artifacts (definition, research, plan)?"

**Options:**
- `.docs/work` (default)
- `docs/work`
- `.workflow`
- Custom path

Repeat for other configurable paths if user wants to change them.

### 6. Save Overrides

If user customized any paths, write to `.claude/workflow.local.md`:

```markdown
# Workflow Settings

Local overrides for workflow plugin paths.

## Paths
- work_dir: {selected}
- learnings_dir: {selected}
- agents_dir: {selected}
```

### 7. Confirm

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

## Reset to Defaults

If user selects "Reset to defaults":

1. Delete `.claude/workflow.local.md`
2. Confirm: "Settings reset. Using default paths."
