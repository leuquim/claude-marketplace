---
description: Generate commit message options from staged changes. Optionally specify subfolder for monorepo.
argument-hint: [subfolder]
allowed-tools: Bash, AskUserQuestion
model: claude-haiku-4-5
---

## Task

Generate commit message options for staged changes and commit with user's selection.

## Process

### 1. Determine Repository Path

If `$ARGUMENTS` is provided:
- Use `$ARGUMENTS` as subfolder path (e.g., "api" → "./api")
- Verify it's a git repository

If no argument:
- Use current working directory

### 2. Check Staged Changes

```bash
git -C {repo_path} diff --cached --stat
```

If no staged changes, inform user: "No staged changes to commit. Stage files with `git add` first."

### 3. Get Staged Diff

```bash
git -C {repo_path} diff --cached
```

### 4. Generate Commit Message Options

Analyze the diff and generate 3 commit message options:

1. **Concise** - Single line, under 50 chars, imperative mood
2. **Descriptive** - Subject line + brief body explaining what/why
3. **Conventional** - Using conventional commits format (feat/fix/refactor/docs/chore)

Present as numbered list:

```
Based on staged changes:

1. Fix null check in user validation

2. Fix null check in user validation

   Add defensive check for undefined user object before
   accessing properties to prevent runtime errors.

3. fix(auth): add null check for user object validation

Reply with a number (1-3) to commit, or 'c' for custom message.
```

### 5. Wait for User Selection

Use AskUserQuestion with formatted options:
- Question: "Which commit message?"
- Option format: Title/type on first line, actual commit message on second line

Example options:
- Option 1:
  - label: "Concise"
  - description: "Fix null check in user validation"
- Option 2:
  - label: "Descriptive"
  - description: "Fix null check in user validation\n\nAdd defensive check for undefined user object..."
- Option 3:
  - label: "Conventional"
  - description: "fix(auth): add null check for user object validation"
- Option 4:
  - label: "Custom"
  - description: "Provide your own message"

### 6. Commit Changes

When user selects (1, 2, or 3):

```bash
git -C {repo_path} commit -m "{selected_message}"
```

If user selects "Custom":
- Ask for their custom message
- Commit with that message

## Rules

- Do not add Co-Authored-By or attribution to Claude
- Do not modify git config
- Do not push (commit only)
- Do not use --no-verify or skip hooks
- Keep option 1 under 50 characters
- Use imperative mood ("Add" not "Added")

## Conventional Commits Reference

| Prefix | Use for |
|--------|---------|
| feat | New feature |
| fix | Bug fix |
| refactor | Code restructuring |
| docs | Documentation |
| chore | Maintenance, deps |
| test | Tests |
| style | Formatting |

Argument: $ARGUMENTS
