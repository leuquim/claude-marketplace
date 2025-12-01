---
name: prompt-engineer
description: Create, review, and optimize prompts for Claude. Use when writing system prompts, CLAUDE.md instructions, agent definitions, skill prompts, or any text that instructs Claude. Triggers on requests to "write a prompt", "improve this prompt", "review prompt", "optimize instructions", or when creating agents/skills/CLAUDE.md files.
---

# Prompt Engineer

Create high-quality prompts that activate the right knowledge patterns and produce consistent, optimal results.

## Core Model: How Prompts Work

Prompts act as filters that bias which learned patterns activate. The same knowledge exists in the model - prompts shape which subset surfaces and how it combines.

Key insight: You're steering existing capabilities, not unlocking hidden ones.

## Prompt Structure

Use this sequence. Omit sections not needed for the task.

```
1. Role/Identity     - Who Claude is acting as
2. Context           - Background, constraints, environment
3. Task              - What to do (imperative form)
4. Format            - Output structure, length, style
5. Examples          - Concrete input/output pairs (optional but powerful)
6. Guardrails        - What to avoid, boundaries
```

## Writing Principles

### Be Explicit Over Implicit

Claude 4.x/Opus 4.5 follows instructions literally. State what you want directly.

Bad: "Create a dashboard"
Good: "Create a dashboard with user metrics, activity graphs, and export functionality"

Bad: "Be thorough"
Good: "Include edge cases, error handling, and performance considerations"

### Provide Rationale (The "Why")

Explaining motivation improves generalization beyond the literal instruction.

Bad: "Never use ellipses"
Good: "Never use ellipses - the output will be read by text-to-speech which cannot pronounce them"

Bad: "Keep responses under 200 words"
Good: "Keep responses under 200 words - users are reading on mobile devices"

### Match Register to Desired Output

Prompt style influences response style. Technical language produces technical responses. Casual language produces casual responses.

### Use Imperative Form

Write instructions as commands, not descriptions.

Bad: "The assistant should validate input"
Good: "Validate all input before processing"

### Constrain Degrees of Freedom

More specific = more consistent. Only leave freedom where variation is acceptable.

High freedom: "Respond helpfully" (many valid outputs)
Low freedom: "Respond with a JSON object containing 'status' and 'message' fields" (narrow valid outputs)

## Claude 4.x / Opus 4.5 Specifics

### Word Sensitivity

Avoid "think" and variants when extended thinking is disabled. Use instead:
- consider
- evaluate
- analyze
- assess
- examine

### Dial Back Aggressive Language

Opus 4.5 is highly responsive. Aggressive prompting causes overtriggering.

Bad: "CRITICAL: You MUST always..."
Good: "Always..."

Bad: "IMPORTANT: Never under any circumstances..."
Good: "Never..."

### Request Scope Explicitly

Claude 4.x won't exceed scope unless asked. If you want comprehensive output:

"Include edge cases and error scenarios"
"Go beyond the basics - provide a complete implementation"
"Consider security, performance, and maintainability"

### Guard Against Over-Engineering

Add explicit constraints to prevent unnecessary complexity:

"Only make changes directly requested. Keep solutions simple and focused. Don't add features beyond what was asked."

## Examples in Prompts

Examples are powerful - Claude scrutinizes them closely.

### Good Example Usage

```
Format responses as:
- Finding: [what was observed]
- Impact: [why it matters]
- Recommendation: [what to do]

Example:
- Finding: Authentication tokens never expire
- Impact: Stolen tokens grant permanent access
- Recommendation: Implement 24-hour token expiration
```

### Avoid

- Examples that accidentally demonstrate unwanted patterns
- Too many examples (diminishing returns after 2-3)
- Examples that contradict instructions

## Common Patterns

### Role Priming

```
You are a [role] with expertise in [domain].
You prioritize [values] and approach problems by [method].
```

### Output Scaffolding

```
Structure your response as:
1. Summary (2-3 sentences)
2. Analysis (bullet points)
3. Recommendation (single paragraph)
```

### Constraint Layering

```
Requirements:
- Must: [non-negotiable constraints]
- Should: [strong preferences]
- May: [optional enhancements]
```

### Conditional Behavior

```
If [condition A]: [behavior A]
If [condition B]: [behavior B]
Otherwise: [default behavior]
```

## Review Checklist

When reviewing/improving prompts, verify:

1. **Clarity**: Can each instruction be interpreted only one way?
2. **Completeness**: Are all requirements stated, not assumed?
3. **Consistency**: Do instructions align (no contradictions)?
4. **Conciseness**: Is every sentence earning its place?
5. **Specificity**: Are degrees of freedom appropriate for the task?
6. **Format**: Is desired output structure explicit?
7. **Rationale**: Are key constraints explained (the "why")?
8. **Tone**: Does prompt register match desired output register?
9. **Opus 4.5**: No aggressive caps/emphasis? No "think" without extended thinking?

## Anti-Patterns to Fix

| Anti-Pattern | Problem | Fix |
|--------------|---------|-----|
| "Be really good at this" | Vague, no activation | Specify what "good" means |
| "NEVER EVER DO X!!!" | Aggressive, causes issues | "Do not X" |
| Repeating same instruction | No added value | State once, clearly |
| "Think step by step" (Opus 4.5) | Word sensitivity | "Work through this systematically" |
| Implicit assumptions | Inconsistent results | State explicitly |
| Contradicting instructions | Unpredictable behavior | Resolve conflicts |
| Over-specified trivial tasks | Wastes tokens | Match detail to complexity |

## Workflow

### Writing New Prompts

1. Define the task outcome clearly
2. Identify required constraints and format
3. Draft using the structure above
4. Add examples if output format is specific
5. Review against checklist
6. Test and iterate

### Improving Existing Prompts

1. Identify the failure mode (vague? contradictory? missing context?)
2. Apply relevant principle from above
3. Verify fix doesn't introduce new issues
4. Test the specific case that failed

## References

For detailed guidance on specific prompt types:
- [workflows.md](references/workflows.md) - Multi-step process prompts
- [output-patterns.md](references/output-patterns.md) - Output format patterns
