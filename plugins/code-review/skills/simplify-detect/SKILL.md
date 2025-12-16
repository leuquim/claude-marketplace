---
name: simplify-detect
description: Detect code complexity and simplification opportunities. Use for: unnecessary abstraction, over-engineering, dead code, unclear logic, overly clever code. Language-agnostic patterns.
---

# Code Simplification Detection Skill

Identify opportunities to simplify code for clarity and maintainability.

## Detection Categories

### 1. Unnecessary Abstraction

**Premature generalization:**
- Generic interfaces with single implementation
- Factory patterns for one concrete type
- Strategy pattern with one strategy
- Layers that just pass through to next layer

**Over-parameterization:**
- Functions with >5 parameters
- Config objects with mostly default values
- Feature flags that are always true/false

### 2. Dead Code

**Unreachable code:**
- Code after return/throw statements
- Conditions that are always true/false
- Unused imports/requires
- Commented-out code blocks

**Unused declarations:**
- Functions never called
- Variables assigned but never read
- Exports never imported
- Classes never instantiated

### 3. Overly Complex Logic

**Nested conditionals:**
- >3 levels of if/else nesting
- Switch statements with >10 cases
- Complex boolean expressions (>3 conditions)

**Clever code:**
- Bitwise operations where arithmetic works
- Regex for simple string operations
- One-liners that sacrifice readability
- Ternary chains

### 4. Duplication

**Copy-paste patterns:**
- Near-identical code blocks
- Functions that differ by 1-2 lines
- Repeated magic numbers/strings

**Missed extraction:**
- Long functions (>50 lines)
- Deep callback nesting
- Repeated setup/teardown

### 5. Unnecessary Indirection

**Over-engineering:**
- Dependency injection for static dependencies
- Event systems for synchronous calls
- Message queues for in-process communication
- Microservices for monolith-suitable code

**Wrapper bloat:**
- Thin wrappers that add no value
- Adapters with identical interfaces
- Decorators that don't decorate

## Detection Process

1. **Scan for patterns** - Look for complexity indicators
2. **Check context** - Is complexity justified by requirements?
3. **Identify alternatives** - What simpler approach exists?
4. **Assess impact** - How much clarity would simplification add?

## Output Format

For each finding:

```markdown
### [Severity] {Simplification Type}

**Location:** `file:line`
**Category:** {Abstraction|DeadCode|Complexity|Duplication|Indirection}

**Current Code:**
```{lang}
{complex code snippet}
```

**Issue:** {Why this is unnecessarily complex}

**Simpler Alternative:** {What could replace it}

**Initial Severity:** {Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| Medium | Actively harms readability, blocks understanding |
| Low | Could be simpler but not blocking |

Note: Simplification findings are typically Medium or Low. Code works correctly; it's just harder to maintain than necessary.

## What NOT to Flag

- Complexity required by domain (financial calculations, crypto, etc.)
- Framework-mandated patterns (React hooks, Angular decorators)
- Performance-critical optimizations with comments explaining why
- Code matching established project conventions
- Test utilities and fixtures (often intentionally verbose)

## Language-Specific Patterns

**JavaScript/TypeScript:**
- `Array.reduce` for simple transformations (use map/filter)
- Nested `.then()` chains (use async/await)
- Manual type guards where discriminated unions work

**Python:**
- List comprehensions with >2 conditions
- `**kwargs` passed through multiple layers
- Metaclasses for simple inheritance

**Go:**
- Interface with single method and single implementation
- Empty structs as namespace containers
- Error wrapping without adding context

**Java:**
- AbstractFactoryFactory patterns
- Visitor pattern for 2 types
- Builder for immutable with <5 fields
