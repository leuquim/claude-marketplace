---
description: Multi-agent code review with user-selected agents. Presents available reviewers for intentional dispatch.
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion
---

## Task

Run comprehensive code review by delegating to the orchestrator agent.

## Process

### 1. Determine Scope

If scope is not clear from context, use AskUserQuestion:

**Question:** "What should I review?"
**Options:**
- Recent changes (unstaged git diff)
- Staged changes (git diff --cached)
- Specific files/directory
- Current work item

### 2. Gather Files

Based on scope, collect the file list:

```bash
# Recent changes
git diff --name-only

# Staged changes
git diff --cached --name-only

# Specific path
# Use glob on provided path
```

### 3. Select Review Agents

Use AskUserQuestion with `multiSelect: true` to let the user choose which agents to run.

**Question 1 - Core Analysis:**
| Option | Description |
|--------|-------------|
| security-detect | Injection risks, secrets, auth gaps, OWASP Top 10 |
| performance-detect | N+1 queries, caching, complexity, memory leaks |
| architecture-detect | SOLID violations, coupling, circular dependencies |
| simplify-detect | Over-engineering, dead code, unnecessary abstraction |

**Question 2 - Specialized Analysis:**
| Option | Description |
|--------|-------------|
| changes-detect | Functional changes: behavior, business rules, API contracts |
| frontend-detect | Component architecture, state, render performance, a11y |
| data-detect | Transaction safety, integrity, migrations, race conditions |
| conventions-detect | Naming patterns, organization, import ordering |

Default pre-selection based on file types (show as recommendations):
- Backend files → security, performance, architecture, simplify
- Frontend files → frontend, security, simplify
- Data files → data
- 3+ files → conventions
- Diff-based scope → changes-detect

### 3b. Get Base Branch (if changes-detect selected)

If `changes-detect` was selected, ask for the comparison base:

**Question:** "What base branch should I compare against?"
**Options:** main, master, develop, Other (specify)

### 4. Delegate to Orchestrator

Launch the orchestrator agent with file list AND selected agents:

```
Task(
  subagent_type: "code-review:orchestrator",
  prompt: "Review these files: {file_list}. Run ONLY these agents: {selected_agents}. Base branch: {base_branch}. Write findings to .review/"
)
```

The orchestrator handles:
- Parallel detection with selected agents only
- Verification
- Report synthesis

### 5. Present Results

After orchestrator completes:
- Show summary table
- Highlight critical/high issues
- Offer to run `/review-fix` if issues found

## Rules

- Always determine scope first
- Delegate orchestration to the orchestrator agent
- Present synthesized results to user
