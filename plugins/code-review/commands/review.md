---
description: Run multi-agent code review with detection and verification. Analyzes code for security, performance, architecture, and other issues with false-positive filtering.
argument-hint: [scope] [--domain=X] [--staged] [--diff=branch]
allowed-tools: Task, Read, Grep, Glob, Write, Bash(mkdir:*), Bash(date:*)
---

## Context

Working directory: !`pwd`
Today: !`date +%Y-%m-%d`
Git status: !`git status --short 2>/dev/null || echo "Not a git repository"`

## Task

Run a comprehensive code review on the specified scope.

**Scope:** $ARGUMENTS (default: current directory)

### Process

1. Create output directory structure:
   ```
   mkdir -p .reviews/{today}/findings
   ```

2. Launch orchestrator agent:
   ```
   Task(
     subagent_type: "orchestrator",
     prompt: "Review scope: {scope}. Output directory: .reviews/{today}. {domain_filter_if_specified}"
   )
   ```

3. Report completion with path to `.reviews/{today}/REVIEW.md`

### Scope Interpretation

| Argument | Behavior |
|----------|----------|
| (none) | Review current directory recursively |
| `path/to/file` | Review specific file |
| `path/to/dir` | Review directory recursively |
| `--staged` | Review git staged changes only |
| `--diff=branch` | Review diff against specified branch |
| `--domain=X` | Run only specified domain (security, performance, etc.) |

### Output Structure

```
.reviews/
└── {YYYY-MM-DD}/
    ├── findings/
    │   ├── security.md
    │   ├── performance.md
    │   └── verified.md
    └── REVIEW.md          ← Final report
```
