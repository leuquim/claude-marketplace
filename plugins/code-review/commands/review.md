---
description: Multi-agent code review with intelligent dispatch. Selects relevant agents based on file types and context.
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

### 3. Delegate to Orchestrator

Launch the orchestrator agent with the file list:

```
Task(
  subagent_type: "code-review:orchestrator",
  prompt: "Review these files: {file_list}. Write findings to .review/"
)
```

The orchestrator handles:
- File classification
- Agent selection (security, architecture, performance, data, frontend, conventions, simplify)
- Parallel detection
- Verification
- Report synthesis

### 4. Present Results

After orchestrator completes:
- Show summary table
- Highlight critical/high issues
- Offer to run `/review-fix` if issues found

## Rules

- Always determine scope first
- Delegate orchestration to the orchestrator agent
- Present synthesized results to user
