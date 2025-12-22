---
name: changes-detect
description: Analyze git diff for functional changes. Use for: behavior changes, business rule modifications, API contract changes, user experience changes, data model changes. Helps verify intended changes and identify side effects.
---

# Functional Changes Detection

Identify and categorize functional changes in code diffs to verify intent and detect unintended side effects.

## Purpose

Answer these questions about a diff:
- What behavior actually changed?
- Were intended changes implemented correctly?
- Are there unintended side effects?
- What functionality was preserved?

## Detection Categories

### 1. Behavior Changes

Control flow, algorithms, error handling, return values.

**Patterns:**
- Modified conditionals (if/else, switch, ternary)
- Changed loop logic (iteration, break conditions)
- Added/removed early returns
- Different exception handling
- Modified default values

**Example:**
```diff
- if (user.isActive) {
+ if (user.isActive && user.hasAccess) {
```
Impact: Access check more restrictive

### 2. Business Rule Changes

Validation, calculations, thresholds, workflows.

**Patterns:**
- Changed validation rules
- Modified calculation formulas
- Adjusted thresholds/limits
- Altered state transitions
- Different eligibility criteria

**Example:**
```diff
- if (amount > 1000) {
+ if (amount > 500) {
```
Impact: Threshold lowered, more cases trigger

### 3. User Experience Changes

UI text, navigation, forms, feature visibility.

**Patterns:**
- Changed labels, messages, errors
- Modified navigation/routing
- Altered form behavior (required fields, validation)
- Different loading/error states
- Feature toggles changed

**Example:**
```diff
- <Button disabled={loading}>Submit</Button>
+ <Button disabled={loading || !isValid}>Submit</Button>
```
Impact: Button disabled in additional cases

### 4. API Contract Changes

Endpoints, request/response shapes, status codes.

**Severity indicators:**
- Field added (required) = Breaking
- Field added (optional) = Non-breaking
- Field removed = Breaking
- Field renamed = Breaking
- Type changed = Usually breaking

**Example:**
```diff
  interface UserResponse {
    id: string;
+   email: string;
-   username: string;
  }
```
Impact: Breaking - response shape changed

### 5. Data Model Changes

Schema, fields, relationships, constraints.

**Patterns:**
- Added/removed fields
- Changed types or nullability
- Modified relationships
- Altered indexes or constraints
- Migration implications

### 6. Side Effect Changes

External interactions: DB, APIs, events, logging.

**Patterns:**
- New database operations
- Added/removed API calls
- Changed event emissions
- Modified logging/telemetry

**Example:**
```diff
  async function updateUser(data) {
    await db.users.update(data);
+   await notificationService.send('user-updated', data);
  }
```
Impact: Function now sends notification

## Detection Process

### Step 1: Get Diff Content

```bash
git diff {base_branch}...HEAD -- {files}
```

### Step 2: Parse Changed Hunks

For each file:
- Identify function/method boundaries
- Note added (+) and removed (-) lines
- Preserve context lines for understanding

### Step 3: Categorize Each Change

For each meaningful change:
1. Which category applies?
2. What was the behavior before?
3. What is the behavior now?
4. Who/what is affected?
5. Is this likely intentional or a side effect?

### Step 4: Assess Severity

| Severity | Criteria |
|----------|----------|
| Breaking | External contracts changed, backwards incompatible |
| Significant | Business logic changed, user-visible impact |
| Minor | Internal refactoring, same external behavior |
| Cosmetic | Style/formatting only |

## Output Format

```markdown
### [{Severity}] {Change Description}

**Location:** `file:line`
**Category:** {Behavior|BusinessRule|UX|API|DataModel|SideEffect}

**Before:**
```{lang}
{previous code or behavior}
```

**After:**
```{lang}
{new code or behavior}
```

**Impact:** {Who or what is affected}

**Assessment:**
- Intent: {Likely intentional | Potential side effect | Unclear}
- Scope: {Local | Module | System-wide}
```

## What to Flag

**Always flag:**
- Removed functionality
- Changed conditionals
- Modified return values/shapes
- New or removed external interactions
- Changed error handling

**Flag with context:**
- Added functionality (may be intentional)
- Refactored code (verify same behavior)
- Changed constants/config

**Skip:**
- Pure formatting/style changes
- Comment-only changes
- Import reordering
- Variable renames without behavior change
