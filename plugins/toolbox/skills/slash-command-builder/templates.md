# Slash Command Templates

Ready-to-use templates for common command patterns.

## Basic Command

```markdown
---
description: [What it does] when [trigger condition]
argument-hint: [expected-args]
allowed-tools: Read, Grep, Glob
---

## Task

[Clear instructions for Claude]

Arguments: $ARGUMENTS
```

## Git Workflow Command

```markdown
---
description: [Git operation description]
allowed-tools: Bash(git:*), Read, Grep
argument-hint: [args if needed]
---

## Current State

Branch: !`git branch --show-current`
Status: !`git status --short`
Recent: !`git log --oneline -5`

## Task

[Git workflow instructions]
```

## GitHub Issue Command

```markdown
---
description: Work on GitHub issue - analyze, implement, test
allowed-tools: Bash(gh:*), Bash(git:*), Read, Write, Grep, Glob
argument-hint: [issue-number]
---

## Issue

!`gh issue view $1 --json title,body,labels`

## Task

1. Analyze issue requirements
2. Locate relevant code
3. Implement solution
4. Add tests if needed
5. Prepare commit message
```

## Code Review Command

```markdown
---
description: Review code for bugs, security, and style issues
allowed-tools: Read, Grep, Glob
argument-hint: [file-path] [focus-area]
---

## Target

File: @$1
Focus: $2

## Task

Review for:
1. Logic errors and edge cases
2. Security vulnerabilities
3. Style consistency
4. Performance concerns

Provide specific, actionable feedback.
```

## File Analysis Command

```markdown
---
description: Analyze file structure and suggest improvements
allowed-tools: Read, Grep, Glob
argument-hint: [file-or-pattern]
---

## Target

!`ls -la $1 2>/dev/null || echo "Pattern: $1"`

## Task

Analyze the specified files:
- Structure and organization
- Code quality
- Potential improvements

$ARGUMENTS
```

## Multi-Step Workflow Command

```markdown
---
description: [Workflow name] - step1, step2, step3
allowed-tools: [tools needed for all steps]
argument-hint: [initial-input]
model: claude-sonnet-4-5-20250929
---

## Context

[Gather state needed for workflow]
!`relevant command`

## Workflow

### Step 1: [Name]
[Instructions]

### Step 2: [Name]
[Instructions]

### Step 3: [Name]
[Instructions]

## Input

$ARGUMENTS
```

## Read-Only Analysis Command

```markdown
---
description: [Analysis type] without making changes
allowed-tools: Read, Grep, Glob
disable-model-invocation: true
argument-hint: [target]
---

## Task

Analyze $ARGUMENTS

Report findings only. Do not modify any files.
```

## Restricted Automation Command

```markdown
---
description: [Automated task] with safety checks
allowed-tools: Bash(specific-cmd:*), Read
disable-model-invocation: true
argument-hint: [required-param]
---

## Safety Check

!`[command to verify safe conditions]`

## Task

Only proceed if safety check passes.

[Automation instructions for $ARGUMENTS]
```
