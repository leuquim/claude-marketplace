# Workflow Path Configuration

## Defaults

| Key | Default | Description |
|-----|---------|-------------|
| work_dir | `.docs/work` | Directory for work item artifacts |
| learnings_dir | `.docs/learnings` | Directory for compounded knowledge |
| agents_dir | `.claude/agents` | Directory for project-specific agents |
| settings_file | `.claude/workflow.local.md` | User override file |

## Work Item Structure

| Artifact | Path | Created By |
|----------|------|------------|
| Definition | `{work_dir}/{slug}/definition.md` | `/workflow:1:understand` |
| Research | `{work_dir}/{slug}/research.md` | `/workflow:1:understand` |
| Plan | `{work_dir}/{slug}/plan.md` | `/workflow:2:plan` |
| TODO | `{work_dir}/{slug}/TODO.md` | `/workflow:2:plan` |

## Slug Format

Work item slugs follow the pattern: `{yyyy_mm_dd}_{kebab-case-title}`

Example: `2025_01_06_add-user-authentication`

## Override Mechanism

User overrides are read from `{settings_file}` (default: `.claude/workflow.local.md`).

If the file exists, parse it for path overrides. Format:

```markdown
## Paths
- work_dir: custom/path/here
- learnings_dir: another/path
```

Any key not specified falls back to the default above.
