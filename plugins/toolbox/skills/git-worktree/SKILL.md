---
name: git-worktree
description: Manage Git worktrees for isolated parallel development. Creates, lists, and cleans up worktrees. Use when starting feature work that should be isolated from main branch.
allowed-tools: Bash, AskUserQuestion
---

# Git Worktree Skill

Manage Git worktrees for isolated feature development.

## When to Use

- Starting work on a new feature that needs isolation
- Working on multiple features in parallel
- Reviewing code without switching branches
- Cleaning up after completing feature work

## Script Location

The worktree manager script is at:
```
skills/git-worktree/scripts/worktree-manager.sh
```

Run via bash (WSL environment):
```bash
bash skills/git-worktree/scripts/worktree-manager.sh <command> [args]
```

## Workflow: Create Worktree for Feature

### 1. Get Default Branch

```bash
bash skills/git-worktree/scripts/worktree-manager.sh default-branch
```

### 2. Check if Worktree Exists

```bash
bash skills/git-worktree/scripts/worktree-manager.sh check {slug}
```

If `EXISTS:{path}` returned, worktree already exists - use that path.

### 3. Ask User for Confirmation

Use AskUserQuestion with two questions:

**Question 1: Worktree name**
- Header: "Worktree"
- Question: "What name for the worktree?"
- Options:
  - `{feature-slug}` (suggested based on work item)
  - Custom option always available

**Question 2: Base branch**
- Header: "Base branch"
- Question: "Which branch to create from?"
- Options:
  - `{default-branch}` (from step 1, usually `main`)
  - `develop` (if exists)
  - Current branch name (if different)

### 4. Create Worktree

```bash
bash skills/git-worktree/scripts/worktree-manager.sh create {name} {base-branch}
```

Output will include `CREATED:{path}` with the worktree path.

### 5. Return Path

Return the worktree path so the calling command can use it.

## Commands Reference

### create

```bash
bash skills/git-worktree/scripts/worktree-manager.sh create <branch-name> [from-branch]
```

Creates worktree at `.worktrees/{branch-name}`. Returns:
- `CREATED:{path}` on success
- `EXISTING:{path}` if already exists

### check

```bash
bash skills/git-worktree/scripts/worktree-manager.sh check <name>
```

Returns:
- `EXISTS:{path}` if worktree exists
- `NOT_FOUND` if not

### list

```bash
bash skills/git-worktree/scripts/worktree-manager.sh list
```

Shows all worktrees with branches and status.

### remove

```bash
bash skills/git-worktree/scripts/worktree-manager.sh remove <name>
```

Removes specific worktree. Fails if currently in that worktree.

### cleanup

```bash
bash skills/git-worktree/scripts/worktree-manager.sh cleanup
```

Removes all inactive worktrees (skips current).

### default-branch

```bash
bash skills/git-worktree/scripts/worktree-manager.sh default-branch
```

Returns `main` or `master` based on what exists.

### current-branch

```bash
bash skills/git-worktree/scripts/worktree-manager.sh current-branch
```

Returns current branch name.

## Directory Structure

```
project-root/
├── .worktrees/           # All worktrees live here
│   ├── feature-auth/     # Worktree for auth feature
│   ├── feature-api/      # Worktree for api feature
│   └── ...
├── .gitignore            # Auto-updated to include .worktrees
└── ...
```

## Rules

- Always ask user before creating worktree
- Suggest feature slug as default name
- Detect default branch automatically
- Never force-remove worktrees without user consent
- Keep worktrees in `.worktrees/` directory
