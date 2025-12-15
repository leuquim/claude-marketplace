---
name: performance-detect
description: Detect performance issues in code. Use for: N+1 queries, missing caching, algorithmic complexity, memory leaks, blocking operations, bundle size concerns. Language-agnostic patterns.
---

# Performance Detection Skill

Identify performance bottlenecks and inefficiencies.

## Detection Categories

### 1. N+1 Query Patterns

- Database calls inside loops
- ORM lazy loading in iteration
- Missing eager loading/joins
- Sequential API calls that could be batched

**Patterns:**
```
for .* {
  .*\.(find|query|select|get|fetch)
}

\.forEach.*\.(find|query|select|get|fetch)
```

### 2. Missing Caching

- Repeated expensive computations
- Frequent identical database queries
- External API calls without caching
- File reads on every request

**Signs:**
- Same query/computation in hot paths
- No TTL or invalidation logic nearby
- Missing cache check before expensive operation

### 3. Algorithmic Complexity

- Nested loops over large datasets: O(n²) or worse
- Linear search where hash lookup possible
- Repeated array scans instead of Set/Map
- Sorting in hot paths without necessity

**Patterns:**
```
for .* {
  for .* {           // O(n²)

\.filter\(.*\.find\(  // O(n²)
\.includes\( inside loop  // O(n) per iteration
```

### 4. Memory Issues

- Unbounded collections without limits
- Large objects held in closures
- Missing cleanup of event listeners
- Accumulating data in long-lived processes

**Signs:**
- `push()` without corresponding cleanup
- Event listeners without removal
- Global/module-level caches without eviction
- Large arrays built but never cleared

### 5. Blocking Operations

- Synchronous file I/O in request handlers
- Blocking crypto operations
- Large JSON parsing on main thread
- Missing async/await on I/O operations

**Patterns:**
```
readFileSync|writeFileSync  (in non-startup code)
JSON\.parse\(.*large
crypto\.(pbkdf2Sync|scryptSync)
```

### 6. Resource Exhaustion

- Unbounded pagination/listing
- Missing timeouts on external calls
- No connection pool limits
- Unlimited concurrent operations

## Detection Process

1. **Identify hot paths** - Request handlers, loops, frequently called functions
2. **Check for patterns** - N+1, nested loops, sync I/O
3. **Trace resource lifecycle** - Created, used, cleaned up?
4. **Note context** - Is this startup code or runtime?

## Output Format

```markdown
### [Severity] {Issue Type}

**Location:** `file:line`
**Category:** {N+1|Caching|Complexity|Memory|Blocking|Exhaustion}

**Code:**
```{lang}
{problematic code, 5-10 lines context}
```

**Impact:** {Why this matters - latency, memory, CPU}

**Initial Severity:** {High|Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| High | N+1 in hot path, O(n²) on large data, blocking in handlers |
| Medium | Missing caching opportunity, suboptimal algorithm |
| Low | Minor inefficiency, startup-only blocking |
