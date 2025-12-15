---
name: frontend-detect
description: Detect frontend quality issues. Use for: component architecture, state management, render performance, accessibility, error boundaries. Framework-agnostic with React/Vue/Svelte specifics.
---

# Frontend Quality Detection Skill

Identify frontend code quality and performance issues.

## Detection Categories

### 1. Component Architecture

**Oversized Components:**
- Components >300 lines
- Multiple responsibilities in one component
- Mixed concerns (data fetching + UI + business logic)

**Poor Composition:**
- Prop drilling more than 2 levels
- Duplicated component logic
- Missing extraction of reusable patterns

### 2. State Management

**Common Issues:**
- Local state that should be lifted
- Global state for local concerns
- Missing state normalization
- Derived state stored instead of computed

**Anti-patterns:**
```jsx
// Storing derived state
const [fullName, setFullName] = useState('')
useEffect(() => {
  setFullName(`${firstName} ${lastName}`)
}, [firstName, lastName])
```

### 3. Render Performance

**Unnecessary Re-renders:**
- Missing memoization on expensive components
- Inline function/object props
- Missing dependency arrays
- Large lists without virtualization

**Patterns:**
```jsx
<Component onClick={() => handle()} />  // New function each render
<Component style={{ color: 'red' }} />  // New object each render
```

### 4. Error Handling

- Missing error boundaries
- Unhandled promise rejections
- Silent failures in async operations
- No loading/error states for data fetching

### 5. Accessibility

- Missing ARIA labels on interactive elements
- Images without alt text
- Missing keyboard navigation
- Poor focus management

### 6. Memory Leaks

- Event listeners not cleaned up
- Subscriptions without unsubscribe
- Timers without clearTimeout/clearInterval
- Async operations completing after unmount

**Pattern:**
```jsx
useEffect(() => {
  const timer = setInterval(...)
  // Missing: return () => clearInterval(timer)
}, [])
```

## Framework-Specific

**React:**
- Missing keys in lists
- useEffect dependency issues
- State updates on unmounted components

**Vue:**
- Watchers without cleanup
- Missing v-bind:key
- Reactive refs misuse

**Svelte:**
- Missing reactive declarations
- Store subscription leaks

## Output Format

```markdown
### [Severity] {Issue Type}

**Location:** `file:line`
**Category:** {Component|State|Performance|Errors|A11y|Memory}

**Code:**
```{lang}
{problematic code}
```

**Impact:** {UX, performance, or maintainability effect}

**Initial Severity:** {High|Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| High | Memory leaks, missing error boundaries, major a11y issues |
| Medium | Performance issues, poor state management |
| Low | Component size, minor optimizations |
