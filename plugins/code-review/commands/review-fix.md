---
description: Resume and execute fixes from a code review with checkpoint persistence.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

## Task

Resume a code review and work through fixes from TODO.md with checkpoint persistence. Each fix updates TODO.md, enabling mid-session interruption and resume by a different agent.

## Process

### 1. Find Review Directory

Locate the most recent review for the current branch:

```bash
branch=$(git rev-parse --abbrev-ref HEAD)
workspace_root="{find workspace root as in /review}"
review_dir=$(ls -td ${workspace_root}/.reviews/${branch}/*/ 2>/dev/null | head -1)
```

**If no review found for current branch:**

Check if other branches have reviews:
```bash
ls -d ${workspace_root}/.reviews/*/ 2>/dev/null
```

If reviews exist for other branches, use AskUserQuestion:

**Question:** "No review found for branch '{branch}'. What would you like to do?"
**Options:**
- Run /review for current branch
- Use review from {other_branch} ({timestamp})
- Specify path manually

If no reviews exist at all:
```
No reviews found in {workspace_root}/.reviews/

Run `/review` first to create a code review.
```
Then stop.

### 2. Validate Review Directory

Check for required files in `{review_dir}`:

| File | Required | Purpose |
|------|----------|---------|
| README.md | Yes | Entry point with context |
| TODO.md | Yes | Actionable checklist |
| findings/verified.md | Yes | Verified findings |
| REVIEW.md | No | Full report (reference only) |

**If TODO.md is missing but REVIEW.md exists:**

This review was created before TODO.md support. Use AskUserQuestion:

**Question:** "This review doesn't have a TODO.md. Would you like me to generate one from REVIEW.md?"
**Options:**
- Yes, generate TODO.md now
- No, I'll run a new /review instead

If yes, run dependency analysis (Step 8 from /review) and generate TODO.md.

### 3. Parse TODO.md

Read `{review_dir}/TODO.md` and extract:

```
{
  review_timestamp: "{from header}",
  branch: "{from header}",
  status: { completed: n, total: n },
  items: [
    {
      id: "B-001",
      phase: "behavioral",
      checkbox_state: "unchecked" | "checked" | "skipped",
      severity: "Critical",
      category: "security",
      title: "SQL injection fix",
      location: "src/services/auth.ts:67",
      problem: "Unsanitized input in query",
      action: "Use parameterized query",
      depends_on: ["S-001"],
      blocks: ["B-002"],
      reference: "./findings/verified.md#sql-injection",
      fixed_at: null | "{ISO timestamp}"
    },
    ...
  ],
  progress_log: [...]
}
```

**Checkbox state detection:**
- `- [ ]` → unchecked
- `- [x]` → checked (completed)
- `- [~]` → skipped

### 4. Determine Starting Point

Find the first unchecked item whose dependencies are all satisfied:

```
completed_ids = [item.id for item in items if item.checkbox_state == "checked"]

for item in items (in order):
  if item.checkbox_state == "unchecked":
    if all(dep in completed_ids for dep in item.depends_on):
      start_item = item
      break
```

**Show current state:**

```markdown
## Review Progress

**Directory:** {review_dir}
**Branch:** {branch}
**Status:** {completed}/{total} complete, {skipped} skipped

### Completed
{list checked items with [x]}

### Next Up
- [ ] {start_item.id}: {start_item.title}

### Blocked
{items with unsatisfied dependencies}

### Remaining
{other unchecked items}
```

If all items complete or skipped:
```
All items in this review have been addressed.

Summary:
- Completed: {n}
- Skipped: {n}

Run `/review` again to check for any new issues.
```
Then stop.

### 5. Execute Fixes (Loop)

For each remaining item in dependency order:

#### 5a. Preview

```markdown
## Fix {current}/{remaining}: {id} - {title}

**Severity:** {severity}
**Category:** {category}
**Location:** `{location}`

### Problem
{problem description}

### Proposed Action
{action}

### Dependencies
- **Completed:** {list completed deps, or "None"}
- **Blocks:** {list of items this unblocks}

### Reference
See: [{reference_filename}]({reference})
```

#### 5b. Confirm

Use AskUserQuestion:

**Question:** "How should I proceed with this fix?"
**Options:**
- Apply this fix
- Show me the reference details first
- Skip this fix
- Stop here (save progress)

**If "Show reference":** Read and display the referenced findings file section, then re-ask.

**If "Skip":** Ask for reason, then update TODO.md (see 5d) and continue to next.

**If "Stop":** Go to Step 6 (Summary).

#### 5c. Apply Fix

If user approves:

1. **Read reference** for full context if needed
2. **Make changes** using Edit tool
3. **Show diff** of what changed
4. **Syntax check** if applicable:
   - `.js/.ts` → `node --check {file}` or TypeScript check
   - `.py` → `python -m py_compile {file}`
   - `.php` → `php -l {file}`

```markdown
### Fix Applied

**Changes made:**
- `{file}:{lines}` - {description}

**Syntax check:** {pass/fail}

{Show relevant diff}
```

#### 5d. Update TODO.md (CRITICAL)

**Immediately after each fix or skip**, update TODO.md to persist progress:

**For completed fix:**
```markdown
# Before:
- [ ] **Fix** | Critical | security

# After:
- [x] **Fixed** | Critical | security
...
- **Fixed at:** {ISO timestamp}
```

**For skipped fix:**
```markdown
# Before:
- [ ] **Fix** | Low | conventions

# After:
- [~] **Skipped** | Low | conventions
...
- **Reason:** {user-provided reason}
```

**Update status line:**
```markdown
**Status:** {n+1}/{total} complete
```

**Append to Progress Log:**
```markdown
| {ISO timestamp} | Fixed | {id} | {brief note} |
```

Also update `{review_dir}/README.md` summary table Fixed column if present.

#### 5e. Continue or Stop

After each fix:

**Question:** "Fix applied. What's next?"
**Options:**
- Continue to next fix
- I need to adjust this manually first
- Stop here

**If "adjust manually":** Pause and inform user:
```
Pausing for manual adjustment. When ready, run `/review-fix` to continue.
Progress has been saved to TODO.md.
```
Then stop.

**If "Stop":** Go to Step 6.

**Otherwise:** Continue to next unchecked item with satisfied dependencies.

### 6. Summary

When complete or stopped:

```markdown
## Session Complete

**Review:** {review_dir}
**Session duration:** {start to now}

### This Session
- Fixes applied: {n}
- Fixes skipped: {n}

### Overall Progress
- Total: {completed + skipped}/{total}
- Remaining: {unchecked count}

### Files Modified
{list of files changed this session}

### Next Steps
- Review changes: `git diff`
- Run tests if applicable
- Commit when ready: `git add . && git commit`
- To continue remaining fixes: `/review-fix`
```

## Dependency Heuristics

Use these patterns to detect when fixes should be reordered:

**Structural changes (do first):**
- Keywords: split, extract, move, rename, reorganize
- Pattern: "god class", "single responsibility"
- Effect: File/module reorganization

**Interface changes (do second):**
- Keywords: signature, parameter, return type, API, contract
- Pattern: Public method/function changes
- Effect: Calling code must be updated

**Shared code dependencies:**
- Utils, helpers, shared services mentioned
- Multiple findings reference same file
- Base class / parent component changes

**Data layer dependencies:**
- Migration/schema changes before application code
- Model changes before repository/service changes

## Rules

### Do
- Parse findings from TODO.md file, not conversation history
- Update TODO.md immediately after each fix (checkpoint)
- Respect dependency order (don't skip blocked items)
- Show preview before applying each fix
- Wait for explicit user approval

### Avoid
- Auto-committing changes
- Applying multiple fixes at once
- Proceeding without confirmation
- Continuing if user says stop
- Modifying items out of dependency order

## Edge Cases

### Circular Dependencies

If items have circular dependencies, group them:
```
Items {A} and {B} have circular dependencies.
These should be fixed together. Applying {A} first, then {B}.
```

### Manual TODO.md Edits

If user has manually checked items or reordered:
- Trust the checkbox state from file
- Don't recompute order
- Warn if dependencies appear violated:
  ```
  Note: {B-001} is checked but its dependency {S-001} is not.
  Proceeding with remaining items as ordered.
  ```

### Missing Reference Files

If a reference link points to a missing file:
```
Reference file not found: {path}
Showing item details from TODO.md instead.
```
