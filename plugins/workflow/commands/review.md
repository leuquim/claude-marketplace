---
description: Multi-agent code review with intelligent dispatch. Selects relevant agents based on file types and context. Runs agents in parallel and synthesizes findings.
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion
---

## Task

Run comprehensive code review using specialized agents, intelligently selecting which agents to dispatch based on the files being reviewed.

## Process

### 1. Determine Review Scope

If scope is not clear from context, use AskUserQuestion:

**Question:** "What should I review?"
**Options:**
- Recent changes (unstaged git diff)
- Staged changes (git diff --cached)
- Branch changes (compared to base branch)
- Specific files/directory
- Current work item (from `.docs/work/{slug}/`)

### 2. Gather Files to Review

Based on scope:

**Recent changes:**
```bash
git diff --name-only
```

**Staged changes:**
```bash
git diff --cached --name-only
```

**Branch changes:**
```bash
# Detect base branch (main or master)
git show-ref --verify --quiet refs/heads/main && echo main || echo master
# Get files changed in current branch vs base
git diff <base-branch>...HEAD --name-only
```

**Work item:**
- Read `.docs/work/{slug}/research.md` for affected files
- Read `.docs/work/{slug}/TODO.md` for completed tasks

**Specific path:**
- Glob the provided path for relevant files

### 3. Classify Files and Select Agents

Analyze the file list and determine which agents are relevant:

#### File Type Classification

| File Pattern | Category |
|--------------|----------|
| `*.js`, `*.ts`, `*.jsx`, `*.tsx`, `*.py`, `*.go`, `*.java`, `*.rb`, `*.php`, `*.rs`, `*.cs` | code |
| `*.sql`, `**/migrations/**`, `**/models/**`, `**/entities/**`, `*.prisma`, `**/schema.*` | data |
| `*.css`, `*.scss`, `*.less`, `*.styled.*`, `*.module.css` | styles |
| `*.html`, `*.vue`, `*.svelte`, `*.blade.php` | templates |
| `*.json`, `*.yaml`, `*.yml`, `*.toml`, `*.env*`, `*config*` | config |
| `*.md`, `*.txt`, `*.rst` | docs |
| `*.test.*`, `*.spec.*`, `**/__tests__/**`, `**/test/**` | tests |

#### Agent Selection Matrix

| Agent | When to Include |
|-------|-----------------|
| **security-sentinel** | Always for `code`, `config`, `templates`. Skip for `styles`, `docs` only. |
| **architecture-strategist** | For `code` with 3+ files, or any module/directory review. Skip for single files, `styles`, `docs`, `config` only. |
| **code-simplifier** | Always for `code`, `templates`. Skip for `styles`, `docs`, `config` only. |
| **performance-oracle** | For `code` with loops, queries, or data processing. Include for `data` files. Skip for `styles`, `docs`, `config`, simple CRUD. |
| **data-integrity-guardian** | Only when `data` files present (migrations, models, schemas, SQL). Skip otherwise. |
| **frontend-quality-reviewer** | For frontend files (`*.jsx`, `*.tsx`, `*.vue`, `*.svelte`, or files in `components/`, `pages/`, `views/`). Skip for backend-only code. |

#### Selection Logic

```
files = gather_files()
categories = classify_files(files)

agents = []

# Always consider these three core agents
if 'code' in categories or 'templates' in categories:
    agents.append('security-sentinel')
    agents.append('code-simplifier')

if 'code' in categories and (file_count >= 3 or is_module_review):
    agents.append('architecture-strategist')

# Conditional agents
if 'data' in categories:
    agents.append('data-integrity-guardian')

if 'code' in categories and has_complex_logic(files):
    agents.append('performance-oracle')

if is_frontend_code(files):  # .jsx, .tsx, .vue, .svelte, or in components/pages/views/
    agents.append('frontend-quality-reviewer')

# Project-specific agents (from .claude/agents/)
project_agents = discover_project_agents()  # Glob .claude/agents/*.md
for agent in project_agents:
    if agent.matches_files(files):  # Check agent description for relevance
        agents.append(agent)

# Minimum: at least security + simplifier for any code
if len(agents) == 0 and has_any_code(files):
    agents = ['security-sentinel', 'code-simplifier']
```

### 3b. Discover Project Agents

Check for project-specific agents created by `/workflow-init`:

```bash
# Check for .claude/agents/*.md
```

For each discovered agent:
1. Read the agent file
2. Check if its description matches the files being reviewed
3. Include if relevant to the current review scope

Project agents run alongside generic workflow agents, providing stack-specific review.

### 4. Launch Selected Agents in Parallel

Use the Task tool to spawn ALL selected agents in a SINGLE message.

**Agent: security-sentinel** (if selected)
```
Review these files for security vulnerabilities:

{file list}

Focus on: injection risks, input validation, hardcoded secrets, auth/authz issues, OWASP Top 10.

Return a structured security report.
```

**Agent: architecture-strategist** (if selected)
```
Review the architecture of these files:

{file list}

Focus on: SOLID principles, coupling analysis, circular dependencies, design patterns, component boundaries.

Return a structured architecture report.
```

**Agent: code-simplifier** (if selected)
```
Review these files for simplification opportunities:

{file list}

Focus on: unnecessary complexity, over-abstraction, dead code, clarity improvements.

Return a structured simplification report.
```

**Agent: performance-oracle** (if selected)
```
Review these files for performance issues:

{file list}

Focus on: algorithmic complexity, N+1 queries, caching opportunities, memory leaks, rendering performance.

Return a structured performance report.
```

**Agent: data-integrity-guardian** (if selected)
```
Review these files for data integrity issues:

{file list}

Focus on: transaction safety, referential integrity, migration risks, audit coverage, constraint gaps.

Return a structured data integrity report.
```

**Agent: frontend-quality-reviewer** (if selected)
```
Review these frontend files for code quality:

{file list}

Focus on: component architecture, codebase pattern consistency, state management, render performance, error handling, side effects.

Return a structured frontend quality report.
```

### 5. Synthesize Findings

Combine reports from all dispatched agents:

```markdown
# Code Review Report

> Review of {scope description}
> Agents dispatched: {list of agents used}

## Summary

| Category | Issues | Critical | High | Medium | Low |
|----------|--------|----------|------|--------|-----|
| Security | {n} | {n} | {n} | {n} | {n} |
| Architecture | {n} | {n} | {n} | {n} | {n} |
| Simplification | {n} | {n} | {n} | {n} | {n} |
| Performance | {n} | {n} | {n} | {n} | {n} |
| Data Integrity | {n} | {n} | {n} | {n} | {n} |
| Frontend Quality | {n} | {n} | {n} | {n} | {n} |
| **Total** | {n} | {n} | {n} | {n} | {n} |

## Critical & High Priority Issues

{List all critical and high issues from all agents, ordered by severity}

### [{Severity}] {Issue Title}

**Category:** {Security/Architecture/Simplification/Performance/Data/Frontend}
**Location:** `file:line`
**Description:** {issue}
**Recommendation:** {fix}

---

## Medium Priority Issues

{List medium issues}

---

## Low Priority / Suggestions

{List low priority items}

---

## Agent Reports

<details>
<summary>{Agent Name} Report</summary>

{Full agent output}

</details>

{Repeat for each dispatched agent}
```

### 6. Present to User

After synthesis:
1. Note which agents were dispatched and why
2. Show the summary table
3. Highlight critical/high issues requiring immediate attention
4. Ask if user wants to see full details or address specific issues

## Examples

### Example 1: CSS-only changes
```
Files: styles/button.css, styles/form.css

Agents dispatched: None (styles only, no code review needed)

Result: "These are style-only changes. No code review agents applicable. Consider visual review instead."
```

### Example 2: API endpoint changes
```
Files: src/api/users.ts, src/api/auth.ts, src/middleware/auth.ts

Agents dispatched:
- security-sentinel (API code with auth)
- architecture-strategist (3+ code files)
- code-simplifier (code files)
- performance-oracle (API endpoints may have query patterns)
```

### Example 3: Database migration
```
Files: migrations/20240101_add_user_roles.sql, src/models/user.ts

Agents dispatched:
- security-sentinel (code + schema)
- data-integrity-guardian (migration + model)
- code-simplifier (model code)
```

### Example 4: Single utility function
```
Files: src/utils/format.ts

Agents dispatched:
- security-sentinel (code file)
- code-simplifier (code file)
# architecture-strategist skipped: single file
# performance-oracle skipped: simple utility
# data-integrity-guardian skipped: no data files
```

## Rules

- MUST classify files before selecting agents
- MUST run selected agents in parallel (single Task tool call)
- MUST explain which agents were dispatched and why
- SKIP agents when clearly not applicable
- SYNTHESIZE findings - don't just dump reports
- PRIORITIZE by severity across all categories
- DEDUPLICATE overlapping findings
