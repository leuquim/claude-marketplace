# Mique Plugins Marketplace

Personal Claude Code plugin marketplace.

---

## Structure

```
claude-plugins/
├── .claude-plugin/
│   ├── marketplace.json        # Marketplace catalog
│   └── plugin.json             # Root plugin config
├── plugins/
│   ├── workflow/               # Dev workflow plugin
│   └── core/                   # Core utilities plugin
└── TODO.md
```

---

## Plugins

### workflow

Complete development workflow: define → research → plan → work → review → compound.

**Commands:**
- `/define` - Clarify requirements, create definition.md
- `/research` - Parallel agents find patterns, files, knowledge
- `/plan` - Create plan.md + TODO.md with phases
- `/work` - Execute phases in worktree isolation
- `/review` - Multi-agent code review with smart dispatch
- `/compound` - Capture learnings to .docs/learnings/

**Agents:**
- `vector-research` - Semantic search via code-vector-cli
- `repo-analyst` - Docs and compounded knowledge search
- `security-sentinel` - OWASP, injection, secrets, auth
- `architecture-strategist` - SOLID, coupling, patterns
- `performance-oracle` - Big O, N+1, caching, memory
- `code-simplifier` - Complexity, dead code, over-abstraction
- `data-integrity-guardian` - Transactions, constraints, migrations

**Skills:**
- `plan` - TODO.md template and planning guidelines
- `git-worktree` - Worktree management script
- `compound` - Learning documentation template
- `code-vector-search` - Semantic search CLI reference

### core

Core utilities for git and plugin development.

**Commands:**
- `/commit` - Generate commit message options from staged changes (uses haiku)

**Skills:**
- `agent-builder` - Design and build Claude agents
- `prompt-engineer` - Create and optimize prompts
- `slash-command-builder` - Create slash commands

---

## Backlog

### Optional Additions

**Research Agents:**
- `best-practices-researcher` - External docs, community standards
- `git-history-analyzer` - Commit patterns, problem origins

**Skills:**
- `file-todos` - Extract TODO/FIXME from codebase

---

## Quality Improvements Pending

From comprehensive review:

1. **Remove aggressive caps** - Replace "MUST", "NEVER" with rationale-based guidance
2. **Shorten descriptions** - Under 100 chars for commands
3. **Add allowed-tools** - Missing from skill frontmatter
4. **Explicit workflows** - Step-by-step instead of descriptive paragraphs
