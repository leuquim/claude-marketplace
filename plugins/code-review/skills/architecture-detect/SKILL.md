---
name: architecture-detect
description: Detect architectural issues in code. Use for: SOLID violations, coupling problems, circular dependencies, missing abstractions, layering violations. Language-agnostic structural analysis.
---

# Architecture Detection Skill

Identify structural and design issues.

## Detection Categories

### 1. SOLID Violations

**Single Responsibility:**
- Classes/modules doing multiple unrelated things
- Functions with many responsibilities
- Mixed concerns (UI + business logic + data access)

**Open/Closed:**
- Switch statements that grow with new types
- Type checks that require modification for extension

**Dependency Inversion:**
- High-level modules importing low-level details
- Direct instantiation of dependencies
- Missing interfaces/abstractions

### 2. Coupling Issues

**Tight Coupling:**
- Direct dependencies on concrete implementations
- Shared mutable state across modules
- Deep knowledge of other module internals

**Signs:**
```
import { specificImpl } from './deep/nested/path'
otherModule.internalMethod()
sharedState.modify()
```

### 3. Circular Dependencies

- Module A imports B, B imports A
- Indirect cycles through intermediate modules
- Barrel files creating hidden cycles

**Detection:**
- Trace import chains
- Check for bidirectional dependencies
- Look for late/lazy imports (often hiding cycles)

### 4. Missing Abstractions

- Repeated patterns without shared abstraction
- Copy-pasted code with minor variations
- Direct usage where interface would help

### 5. Layering Violations

**Common layers:** Controller → Service → Repository → Database

**Violations:**
- Controllers directly accessing database
- Services importing UI components
- Repositories containing business logic

### 6. God Objects

- Classes with too many methods (>15-20)
- Modules with too many exports
- Single file doing everything

## Output Format

```markdown
### [Severity] {Issue Type}

**Location:** `file:line` (or module/directory level)
**Category:** {SOLID|Coupling|Circular|Abstraction|Layering|GodObject}

**Evidence:**
{description of structural issue}

**Impact:** {maintainability, testability, extensibility}

**Initial Severity:** {High|Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| High | Circular dependencies, layering violations, god objects |
| Medium | Missing abstractions, tight coupling |
| Low | Minor SOLID issues, could-be-better patterns |
