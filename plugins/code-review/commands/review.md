---
description: Multi-agent code review with user-selected agents. Presents available reviewers for intentional dispatch.
allowed-tools: Read, Glob, Grep, Bash, Task, Write, AskUserQuestion
---

## Task

Run comprehensive code review with user-selected detection agents. All user interaction happens in this command before delegating detection work to agents.

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

### 4. Get Base Branch (if changes-detect selected)

If `changes-detect` was selected, ask for the comparison base:

**Question:** "What base branch should I compare against?"
**Options:** main, master, develop, Other (specify)

### 5. Launch Detection Agents (Parallel)

Create output directory:
```bash
mkdir -p .review/findings
```

Launch selected detection agents in parallel using Task tool:

```
# For most agents:
Task(
  subagent_type: "code-review:{domain}-detect",
  prompt: "Review these files: {file_list}. Invoke the {domain}-detect skill. Write findings to .review/findings/{domain}.md"
)

# For changes-detect specifically:
Task(
  subagent_type: "code-review:changes-detect",
  prompt: "Analyze diff from {base_branch} to HEAD for files: {file_list}. Invoke the changes-detect skill. Write findings to .review/findings/changes.md"
)
```

Wait for all detection agents to complete.

### 6. Run Verification

After all detection agents complete, run verification on combined findings:

```
Task(
  subagent_type: "code-review:verification",
  prompt: "Verify all findings in .review/findings/*.md. Invoke the verification skill. Write validated findings to .review/findings/verified.md"
)
```

### 7. Synthesize Report

Read verified findings and generate final report to `.review/REVIEW.md`:

```markdown
# Code Review Report

**Scope:** {files/directories reviewed}
**Date:** {timestamp}
**Agents:** {list of detection agents used}

## Summary

| Severity | Detected | Verified | Filtered |
|----------|----------|----------|----------|
| Critical | X | Y | Z |
| High | X | Y | Z |
| Medium | X | Y | Z |
| Low | X | Y | Z |

---

## Critical Findings

{verified critical findings}

## High Priority Findings

{verified high findings}

## Medium Priority Findings

{verified medium findings}

## Low Priority Findings

{verified low findings}

---

## Recommendations

1. {prioritized actions based on findings}
```

### 8. Present Results

- Show summary table to user
- Highlight critical/high severity issues
- Offer to run `/review-fix` if actionable issues found

## Rules

- Complete all user questions (steps 1-4) before launching any agents
- Launch detection agents in parallel for efficiency
- Run verification only after all detection completes
- Present synthesized results, not raw agent output
