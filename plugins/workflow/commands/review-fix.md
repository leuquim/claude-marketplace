---
description: Work through review findings in optimal dependency order. Analyzes review output and fixes issues one by one with user approval.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion
---

## Task

Analyze the code review just performed, determine optimal fix order based on dependencies, and work through fixes one by one with user approval.

## Prerequisites

This command requires a `/review` to have been run in the current conversation.

If no review findings are in context:
```
No review findings found in this conversation.

Run `/review` first, then use `/review-fix` to work through the findings.
```
Then stop.

## Process

### 1. Extract Findings

Parse the review output from conversation history. Build a list of findings:

```
{
  id: 1,
  severity: "critical|high|medium|low",
  category: "security|architecture|simplification|performance|data|frontend",
  title: "Issue title",
  location: "file:line",
  description: "What the issue is",
  recommendation: "How to fix"
}
```

### 2. Dependency Analysis

Classify each finding by change type:

| Type | Description | Examples |
|------|-------------|----------|
| **structural** | File moves, splits, renames, new files | "Split this god class", "Extract to separate module" |
| **interface** | Signature changes, contract changes, API changes | "Change return type", "Add parameter", "Rename method" |
| **behavioral** | Logic fixes within existing structure | "Add validation", "Fix race condition", "Memoize" |

Build dependency rules:

```
structural → before behavioral fixes in affected files
interface → before fixes in calling code
shared code → before dependent code
parent component → before child component (frontend)
schema/migration → before application code (data)
```

### 3. Build Fix Order

Create a directed graph:
- Nodes = findings
- Edges = "must happen before"

Determine order:
1. Topological sort (respect dependencies)
2. Within same dependency level, sort by:
   - Structural before interface before behavioral
   - Higher severity before lower (as tiebreaker)

### 4. Present Proposed Order

Show the reordered fix plan:

```markdown
## Proposed Fix Order

Based on dependency analysis, here's the optimal order:

### Phase 1: Structural Changes
| # | Severity | Issue | Location | Why First |
|---|----------|-------|----------|-----------|
| 1 | Low | Split UserService into Auth + Profile | src/services/user.ts | Other fixes target code that will move |
| 2 | Medium | Extract validation helpers | src/utils/ | Security fix will use these |

### Phase 2: Interface Changes
| # | Severity | Issue | Location | Why Here |
|---|----------|-------|----------|----------|
| 3 | Medium | Add userId param to audit functions | src/audit.ts | Security fix needs this signature |

### Phase 3: Behavioral Fixes
| # | Severity | Issue | Location | Depends On |
|---|----------|-------|----------|------------|
| 4 | Critical | SQL injection in user lookup | src/services/auth.ts | #1 (file moved), #2 (uses validators) |
| 5 | High | Missing auth check on /admin | src/routes/admin.ts | #3 (audit signature) |
| 6 | Medium | N+1 query in dashboard | src/pages/dashboard.ts | None |

---

**Original severity order would have been:** 4 → 5 → 1 → 2 → 3 → 6
**Dependency order:** 1 → 2 → 3 → 4 → 5 → 6

Fixing in dependency order avoids rework from structural changes.
```

### 5. Confirm Order

Use AskUserQuestion:

**Question:** "Ready to start fixing in this order?"

**Options:**
- Start with fix #1
- Show me the details of a specific fix first
- I want to adjust the order
- Cancel

If "adjust order": Let user specify, then re-present.

### 6. Execute Fixes (One by One)

For each fix in order:

#### 6a. Preview

```markdown
## Fix {N}/{total}: {Title}

**Severity:** {severity}
**Category:** {category}
**Location:** `{file:line}`

### Problem
{description}

### Proposed Solution
{recommendation}

### Files to Modify
- `{file1}` - {what changes}
- `{file2}` - {what changes}
```

#### 6b. Confirm

**Question:** "How should I proceed with this fix?"

**Options:**
- Apply this fix
- Show me the code first
- Skip this fix
- Stop here (remaining fixes will not be applied)

#### 6c. Apply Fix

If user approves:
1. Make the changes
2. Show diff of what changed
3. Run syntax check if applicable (`node --check`, `php -l`, etc.)

```markdown
### Fix Applied

**Changes made:**
- `{file}:{lines}` - {description of change}

**Syntax check:** {pass/fail}

{Show relevant diff}
```

#### 6d. User Review

**Question:** "Review complete. What's next?"

**Options:**
- Continue to next fix
- I need to adjust this fix manually first
- Stop here

If "adjust manually": Pause, let user make changes, then ask when ready to continue.

#### 6e. Repeat

Continue to next fix until:
- All fixes complete
- User stops
- User skips remaining

### 7. Summary

After all fixes (or when stopped):

```markdown
## Review Fix Summary

**Fixes applied:** {n} of {total}
**Fixes skipped:** {n}
**Remaining:** {n}

### Applied
- [x] #{id}: {title} - `{location}`
- [x] #{id}: {title} - `{location}`

### Skipped
- [ ] #{id}: {title} - {reason if given}

### Remaining
- [ ] #{id}: {title}

### Next Steps
- Review the changes before committing
- Run tests if applicable
- Use `/review` again to verify fixes
```

## Rules

### DO
- Parse findings from conversation context only
- Analyze dependencies before proposing order
- Preview each fix before applying
- Wait for explicit user approval
- Show diffs after each fix
- Allow skipping individual fixes
- Track progress throughout

### DO NOT
- Auto-commit any changes
- Proceed without user confirmation
- Apply multiple fixes at once
- Assume severity order is optimal
- Continue if user says stop

## Dependency Heuristics

Use these patterns to detect dependencies:

**Structural changes detected by:**
- "split", "extract", "move", "rename" in recommendation
- "god class", "single responsibility" in description
- File/module reorganization suggestions

**Interface changes detected by:**
- "signature", "parameter", "return type" in recommendation
- "API", "contract", "interface" in description
- Public method/function changes

**Shared code dependencies:**
- Utils, helpers, shared services mentioned
- Multiple findings reference same file
- Base class / parent component changes

**Data layer dependencies:**
- Migration/schema changes before application code
- Model changes before repository/service changes
