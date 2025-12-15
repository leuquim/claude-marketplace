---
name: data-detect
description: Detect data integrity issues in code. Use for: transaction safety, referential integrity, migration risks, audit gaps, race conditions in data access. Database-agnostic patterns.
---

# Data Integrity Detection Skill

Identify data safety and integrity issues.

## Detection Categories

### 1. Transaction Safety

**Missing Transactions:**
- Multiple related writes without transaction wrapper
- Read-modify-write without isolation
- Partial updates that could leave inconsistent state

**Signs:**
```
await model.update(...)
await relatedModel.create(...)  // No transaction wrapper

if (await exists()) {
  await create()  // Race condition
}
```

### 2. Referential Integrity

- Deletes without cascade or orphan handling
- Foreign key references without validation
- Missing existence checks before association

### 3. Race Conditions

- Check-then-act patterns without locking
- Concurrent updates to same record
- Counter increments without atomicity

**Patterns:**
```
const current = await get()
await update(current + 1)  // Race condition

if (!await exists()) {
  await create()  // Race condition
}
```

### 4. Migration Risks

- Destructive migrations without reversibility
- Data migrations mixed with schema changes
- Missing NOT NULL handling for existing data

### 5. Audit Gaps

- Missing created_at/updated_at timestamps
- No record of who made changes
- Soft deletes without deleted_by/deleted_at
- Missing audit trail for sensitive operations

### 6. Data Validation

- Missing validation before database writes
- Type coercion without checks
- Accepting null/undefined where not allowed

## Output Format

```markdown
### [Severity] {Issue Type}

**Location:** `file:line`
**Category:** {Transaction|Integrity|Race|Migration|Audit|Validation}

**Code:**
```{lang}
{problematic code}
```

**Risk:** {Data corruption, inconsistency, or loss scenario}

**Initial Severity:** {Critical|High|Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| Critical | Data corruption risk, missing transactions on financial data |
| High | Race conditions in concurrent paths, referential integrity gaps |
| Medium | Missing audit fields, validation gaps |
| Low | Minor audit improvements, defensive checks |
