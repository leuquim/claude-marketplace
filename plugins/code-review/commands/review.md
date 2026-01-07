---
description: Multi-agent code review with user-selected detection agents.
allowed-tools: Read, Glob, Grep, Bash, Task, Write, AskUserQuestion
---

## Task

Run comprehensive code review with user-selected detection agents. All user interaction happens in this command before delegating detection work to agents.

## Output Location

Reviews are stored at workspace root, grouped by branch and timestamp:

```
{workspace_root}/.reviews/{branch_name}/{timestamp}/
├── README.md            # Entry point with context + navigation
├── TODO.md              # Ordered fixes with checkboxes + doc references
├── REVIEW.md            # Full report
└── findings/
    ├── {domain}.md      # Raw findings per agent
    └── verified.md      # Post-verification findings
```

Example: `.reviews/feature-auth/2025-01-15_14-30/`

## Process

### 0. Find Workspace Root

Reviews go at workspace root, not CWD:
- Look for existing `.claude/` or `.reviews/` in parent directories
- Check if parent contains multiple `.git` subdirectories (sibling repos)
- When uncertain, ask the user

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

Determine output path and create directory:
```bash
# Get branch name and timestamp
branch=$(git rev-parse --abbrev-ref HEAD)
timestamp=$(date +%Y-%m-%d_%H-%M)
output_dir="{workspace_root}/.reviews/${branch}/${timestamp}"

mkdir -p "${output_dir}/findings"
```

Launch selected detection agents in parallel using Task tool:

```
# For most agents:
Task(
  subagent_type: "code-review:{domain}-detect",
  prompt: "Review these files: {file_list}. Invoke the {domain}-detect skill. Write findings to {output_dir}/findings/{domain}.md"
)

# For changes-detect specifically:
Task(
  subagent_type: "code-review:changes-detect",
  prompt: "Analyze diff from {base_branch} to HEAD for files: {file_list}. Invoke the changes-detect skill. Write findings to {output_dir}/findings/changes.md"
)
```

Wait for all detection agents to complete.

### 6. Run Verification

After all detection agents complete, run verification on combined findings:

```
Task(
  subagent_type: "code-review:verification",
  prompt: "Verify all findings in {output_dir}/findings/*.md. Invoke the verification skill. Write validated findings to {output_dir}/findings/verified.md"
)
```

### 7. Synthesize Report

Read verified findings and generate final report to `{output_dir}/REVIEW.md`:

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

### 8. Dependency Analysis

After REVIEW.md is generated, analyze verified findings to determine optimal fix order:

**8a. Parse Verified Findings**

Read `{output_dir}/findings/verified.md` and extract each finding with:
- Title and severity
- Location (file:line)
- Category (security, architecture, etc.)
- Problem description
- Recommended action

**8b. Classify Change Types**

For each finding, determine change type based on recommendation keywords:

| Type | Keywords | Examples |
|------|----------|----------|
| **structural** | split, extract, move, rename, reorganize, god class | "Split this into separate modules" |
| **interface** | signature, parameter, return type, API, contract | "Add userId parameter" |
| **behavioral** | validate, fix, add check, handle, memoize | "Add input validation" |

**8c. Build Dependency Graph**

Create edges based on:
- **structural → behavioral**: Structural changes in file X must happen before behavioral fixes in file X
- **interface → behavioral**: Interface changes must precede fixes in calling code
- **shared → dependent**: Changes to shared utilities before dependent code
- **parent → child**: Parent component changes before child components (frontend)
- **schema → app**: Data schema/migration changes before application code

**8d. Topological Sort**

Order findings respecting dependencies:
1. Respect all dependency edges
2. Within same level, order by: structural > interface > behavioral
3. Within same type, order by: higher severity first (tiebreaker)

**8e. Assign IDs**

Assign phase-prefixed IDs:
- `S-001`, `S-002`: Structural changes
- `I-001`, `I-002`: Interface changes
- `B-001`, `B-002`: Behavioral fixes

### 9. Generate Action Documents

Write `{output_dir}/README.md` and `{output_dir}/TODO.md` to enable resumable reviews.

#### README.md Format

```markdown
# Code Review: {branch}

**Generated:** {timestamp}
**Scope:** {scope description}
**Files Reviewed:** {count}

## Navigation

- **[TODO.md](./TODO.md)** - Ordered fixes with checkboxes (track progress here)
- **[REVIEW.md](./REVIEW.md)** - Full review report
- **[findings/](./findings/)** - Detailed findings by domain

## Summary

| Severity | Count | Fixed |
|----------|-------|-------|
| Critical | {n}   | 0     |
| High     | {n}   | 0     |
| Medium   | {n}   | 0     |
| Low      | {n}   | 0     |

## Detection Agents Used

{list agents with checkmarks for those used}

## Scope Details

### Files Reviewed
{list of files, one per line}

### Git Context
Branch: {branch}
Base: {base_branch if diff-based, otherwise "N/A"}

## How to Resume

Run `/review-fix` to continue from where you left off.
Progress is tracked in TODO.md checkboxes.
```

#### TODO.md Format

```markdown
# Review TODO

**Review:** {timestamp}
**Branch:** {branch}
**Status:** 0/{total} complete

---

## Phase 1: Structural Changes

{For each structural finding:}

### {ID}: {Title}

- [ ] **Fix** | {Severity} | {category}
- **Location:** `{file:line}`
- **Problem:** {problem description}
- **Action:** {recommended action}
- **Blocks:** {list of IDs that depend on this}
- **Reference:** [findings/{domain}.md#{anchor}](./findings/{domain}.md#{anchor})

---

## Phase 2: Interface Changes

{For each interface finding, same format as above, plus:}
- **Depends on:** {list of IDs this depends on}

---

## Phase 3: Behavioral Fixes

{For each behavioral finding, same format}

---

## Progress Log

| Time | Action | Item | Notes |
|------|--------|------|-------|
| {timestamp} | Started | - | Review generated |
```

If no findings in a phase, omit that phase section.

### 10. Present Results

- Show summary table to user
- Highlight critical/high severity issues
- Display paths to output files:
  - `{output_dir}/README.md` - entry point
  - `{output_dir}/TODO.md` - actionable checklist
  - `{output_dir}/REVIEW.md` - full report
- State: "Run `/review-fix` to work through fixes, or check off items in TODO.md manually"

## Rules

- Complete all user questions (steps 1-4) before launching any agents
- Launch detection agents in parallel for efficiency
- Run verification only after all detection completes
- Generate README.md and TODO.md after verification and REVIEW.md synthesis
- Present synthesized results, not raw agent output
