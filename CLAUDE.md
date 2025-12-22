# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Personal Claude Code plugins marketplace with two plugins:
- **workflow**: Development lifecycle (define → research → plan → work → review → compound)
- **core**: Git utilities, prompt engineering, agent building, slash command creation

## Project Structure

```
claude-plugins/
├── .claude-plugin/
│   ├── marketplace.json         # Plugin catalog
│   └── plugin.json              # Root metadata
├── plugins/
│   ├── workflow/                # Dev workflow plugin
│   │   ├── agents/              # 7 specialized agents
│   │   ├── commands/            # 6 slash commands
│   │   └── skills/              # 4 skill modules
│   └── core/                    # Core utilities plugin
│       ├── commands/            # /commit command
│       └── skills/              # 3 skill modules
└── TODO.md                      # Backlog
```

## Plugin Schema

### plugin.json

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "...",
  "author": { "name": "..." },  // Must be object, not string
  "license": "MIT"
}
```

### Command Frontmatter (commands/*.md)

```yaml
---
description: Short description (< 100 chars)
argument-hint: [optional-argument]
allowed-tools: Tool1, Tool2
model: haiku|sonnet|opus
---
```

### Skill Frontmatter (skills/*/SKILL.md)

```yaml
---
name: skill-name
description: When/how to trigger
allowed-tools: Tool1, Tool2
---
```

### Agent Frontmatter (agents/*.md)

```yaml
---
name: agent-name
description: Purpose
tools: Tool1, Tool2
---
```

## Key Patterns

### Multi-Agent Research
`/research` launches 3 parallel agents (Explore + vector-research + repo-analyst) and synthesizes results.

### Workflow Phases
Each phase creates artifacts for the next:
0. `/workflow-init` → `.claude/agents/` (project-specific agents)
1. `/define` → `.docs/work/{slug}/definition.md`
2. `/research` → `.docs/work/{slug}/research.md`
3. `/plan` → `.docs/work/{slug}/plan.md` + `TODO.md`
4. `/work` → Implementation in git worktree
5. `/review` → Multi-agent code review
6. `/compound` → `.docs/learnings/{domain}/{topic}.md`

### Project-Specific Agents
`/workflow-init` discovers the project's tech stack and generates specialized agents:
- Stored in `.claude/agents/` in the target project
- Used automatically by `/work` and `/review`
- Dual-use: support both implementation and review modes
- Created using `agent-builder` and `prompt-engineer` skills

### Skills as Reference
Skills are comprehensive documentation guides (not executable code) teaching tool usage and workflows.

## Vector Search Integration

Uses `code-vector-cli` (optional, requires pre-indexing). Platform-aware: uses WSL on Windows.

Collections: `code_functions`, `code_classes`, `code_files`, `documentation`, `git_history`, `conversations`

## Quality Standards

From TODO.md:
- Descriptions under 100 characters
- Rationale-based guidance (avoid "MUST", "NEVER")
- Include `allowed-tools` in frontmatter
- Explicit step-by-step workflows

## Versioning

Bump plugin versions in `plugins/{name}/.claude-plugin/plugin.json` when making changes:

- **Patch (x.x.1)**: Bug fixes, optimizations, documentation
- **Minor (x.1.0)**: New features, new agents/skills, non-breaking changes
- **Major (1.0.0)**: Breaking changes, removed features, significant restructuring

Users with `autoUpdates: false` won't receive changes until they manually update or reinstall.
