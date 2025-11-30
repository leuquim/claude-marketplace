# Multi-Agent Architecture Patterns

Advanced patterns for building multi-agent systems.

## Pattern 1: Fork + Gather

Run multiple independent analyses in parallel, then synthesize.

**When to Use:**
- Multiple perspectives needed on same input
- Tasks are independent (no dependencies)
- Speed is important

**Structure:**
```
                    ┌─> Agent A ─┐
Main Agent ────────>├─> Agent B ─┼────> Synthesize
                    └─> Agent C ─┘
```

**Implementation:**
```typescript
const result = await query({
  prompt: `Analyze this code from multiple perspectives:
    1. Use code-reviewer for quality analysis
    2. Use security-auditor for security analysis
    3. Use test-runner to verify tests pass

    Launch all three in parallel, then synthesize their findings.`,
  options: {
    agents: {
      "code-reviewer": { /* config */ },
      "security-auditor": { /* config */ },
      "test-runner": { /* config */ }
    }
  }
});
```

**Best Practices:**
- Keep agents focused on single concern
- Define clear output formats for easy synthesis
- Handle partial failures gracefully

---

## Pattern 2: Sequential Pipeline

Chain agents where output of one feeds into next.

**When to Use:**
- Tasks have natural dependencies
- Later stages need earlier results
- Order matters for correctness

**Structure:**
```
Analyze ──> Plan ──> Implement ──> Verify
```

**Implementation:**
```typescript
// Phase 1: Analysis
const analysis = await query({
  prompt: "Analyze the codebase for the feature location",
  options: { agents: { "analyzer": { /* read-only */ } } }
});

// Phase 2: Planning (uses analysis results)
const plan = await query({
  prompt: `Based on analysis, create implementation plan: ${analysis}`,
  resume: sessionId,
  options: { agents: { "planner": { /* read-only */ } } }
});

// Phase 3: Implementation (follows plan)
const implementation = await query({
  prompt: `Execute this plan: ${plan}`,
  resume: sessionId,
  options: { agents: { "implementer": { /* full access */ } } }
});

// Phase 4: Verification
const verification = await query({
  prompt: "Verify the implementation works correctly",
  resume: sessionId,
  options: { agents: { "verifier": { /* test access */ } } }
});
```

**Best Practices:**
- Use session resumption to maintain context
- Each stage should validate previous stage's output
- Include rollback capability for failures

---

## Pattern 3: Hierarchical Delegation

Orchestrator coordinates specialist teams.

**When to Use:**
- Complex tasks requiring multiple skills
- Dynamic delegation based on findings
- Need for high-level coordination

**Structure:**
```
             Orchestrator
                  │
    ┌─────────────┼─────────────┐
    │             │             │
Team Lead A   Team Lead B   Team Lead C
    │             │             │
 ┌──┴──┐       ┌──┴──┐       ┌──┴──┐
Spec A1 Spec A2  ...          ...
```

**Implementation:**
```typescript
const result = await query({
  prompt: "Complete this complex feature request",
  options: {
    agents: {
      "orchestrator": {
        description: "Coordinate complex tasks",
        prompt: `You coordinate specialists:
          - frontend-lead: UI components
          - backend-lead: API and data
          - qa-lead: Testing strategy

          Break down the task and delegate appropriately.`,
        model: "opus"
      },
      "frontend-lead": {
        description: "Frontend implementation",
        prompt: "Implement UI components...",
        tools: ["Read", "Write", "Edit", "Grep", "Glob"]
      },
      "backend-lead": {
        description: "Backend implementation",
        prompt: "Implement API and data layer...",
        tools: ["Read", "Write", "Edit", "Bash", "Grep", "Glob"]
      },
      "qa-lead": {
        description: "Testing strategy",
        prompt: "Design and implement tests...",
        tools: ["Bash", "Read", "Write", "Grep", "Glob"]
      }
    }
  }
});
```

**Best Practices:**
- Use Opus for orchestrator (complex reasoning)
- Use Sonnet for specialists (focused execution)
- Define clear interfaces between levels

---

## Pattern 4: Iterative Refinement

Agent improves output through multiple passes.

**When to Use:**
- Quality requires iteration
- Output needs verification
- Complex outputs benefit from review

**Structure:**
```
Generate ──> Review ──> Refine ──> Review ──> Done
     ^                    │
     └────────────────────┘
```

**Implementation:**
```typescript
let result = await query({
  prompt: "Generate initial implementation",
  options: { agents: { "implementer": { /* config */ } } }
});

for (let i = 0; i < maxIterations; i++) {
  const review = await query({
    prompt: `Review this implementation: ${result}`,
    options: { agents: { "reviewer": { /* config */ } } }
  });

  if (review.approved) break;

  result = await query({
    prompt: `Fix these issues: ${review.findings}`,
    options: { agents: { "implementer": { /* config */ } } }
  });
}
```

**Best Practices:**
- Set maximum iterations to prevent infinite loops
- Define clear approval criteria
- Track what was fixed each iteration

---

## Pattern 5: Consensus Building

Multiple agents must agree before proceeding.

**When to Use:**
- High-stakes decisions
- Need for multiple perspectives
- Want to catch edge cases

**Structure:**
```
                ┌─> Reviewer A ─┐
Input ─────────>├─> Reviewer B ─┼────> Consensus Check ──> Proceed/Escalate
                └─> Reviewer C ─┘
```

**Implementation:**
```typescript
const reviews = await Promise.all([
  query({ prompt: "Review from security perspective", options: { agents: { "security": {} } } }),
  query({ prompt: "Review from performance perspective", options: { agents: { "performance": {} } } }),
  query({ prompt: "Review from maintainability perspective", options: { agents: { "maintainability": {} } } })
]);

const allApproved = reviews.every(r => r.approved);
const criticalIssues = reviews.flatMap(r => r.findings.filter(f => f.severity === 'critical'));

if (criticalIssues.length > 0) {
  // Escalate
} else if (allApproved) {
  // Proceed
} else {
  // Address non-critical issues
}
```

**Best Practices:**
- Define what constitutes consensus
- Have escalation path for disagreements
- Weight opinions by expertise area

---

## Anti-Patterns to Avoid

### 1. Chatty Agents
**Problem:** Agents pass too much data between each other
**Solution:** Define minimal interfaces, pass only what's needed

### 2. Monolithic Orchestrator
**Problem:** Orchestrator does too much work itself
**Solution:** Orchestrator should only coordinate, not execute

### 3. Over-Parallelization
**Problem:** Launching agents for tasks that should be sequential
**Solution:** Identify true dependencies, only parallelize independent work

### 4. Missing Error Boundaries
**Problem:** One agent failure cascades to entire system
**Solution:** Wrap agent calls in error handling, have fallback strategies

### 5. Tool Creep
**Problem:** Agents accumulate tools they don't need
**Solution:** Review tool lists regularly, remove unused capabilities

---

## Performance Optimization

### 1. Batch Similar Tasks
```typescript
// Instead of N separate agents for N files
const result = await query({
  prompt: "Review all these files: [list]",
  options: { agents: { "reviewer": {} } }
});
```

### 2. Use Appropriate Models
```typescript
const agents = {
  "simple-task": { model: "haiku" },    // Fast, cheap
  "standard-task": { model: "sonnet" }, // Balanced
  "complex-task": { model: "opus" }     // Best reasoning
};
```

### 3. Cache Common Context
```typescript
// Load CLAUDE.md with project context
// Agents inherit this automatically
options: {
  settingSources: [".claude/settings.json"]
}
```

### 4. Minimize Tool Calls
```typescript
// Bad: Many small reads
// Good: Read related files together

// Bad: Grep then Read each result
// Good: Grep with context (-C flag)
```
