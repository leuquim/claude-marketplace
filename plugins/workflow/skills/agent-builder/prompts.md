# System Prompt Engineering Guide

How to write effective system prompts for agents.

## The Anatomy of a Good Prompt

```markdown
# Role          <- WHO the agent is
# Capabilities  <- WHAT it can do (tools)
# Success       <- WHEN it's done well
# Output        <- HOW to format results
# Process       <- STEPS to follow
# Boundaries    <- WHAT NOT to do
```

Each section serves a specific purpose. Omitting any reduces effectiveness.

---

## Section: Role

Define WHO the agent is with specificity.

**Bad:**
```markdown
# Role
You help with code.
```

**Good:**
```markdown
# Role
You are a senior TypeScript engineer specializing in React applications.
You have 10 years of experience with frontend architecture and testing.
```

**Why it matters:** Role priming affects reasoning quality. Specific expertise leads to expert-level outputs.

---

## Section: Capabilities

State WHAT the agent can do based on its tools.

**Bad:**
```markdown
# Capabilities
You have access to tools.
```

**Good:**
```markdown
# Capabilities
Your tools allow you to:
- Read source files to understand implementation
- Search for patterns across the codebase with Grep
- Find files matching patterns with Glob
- Execute bash commands for running tests

You cannot modify files in this role.
```

**Why it matters:** Agents perform better when they understand their constraints explicitly.

---

## Section: Success Criteria

Define WHEN the task is complete and done well.

**Bad:**
```markdown
# Success
Do a good job.
```

**Good:**
```markdown
# Success Criteria
A successful review means:
- All critical bugs identified with evidence
- Security vulnerabilities flagged with severity
- No false positives (each issue has code evidence)
- Suggestions are actionable and specific
```

**Why it matters:** Clear criteria prevent premature completion and ensure quality.

---

## Section: Output Format

Specify EXACTLY how results should be structured.

**Bad:**
```markdown
# Output
Return your findings.
```

**Good:**
```markdown
# Output Format
Return results as JSON matching this schema:

```json
{
  "status": "pass|fail",
  "summary": "One sentence overview",
  "findings": [
    {
      "severity": "critical|high|medium|low",
      "file": "path/to/file.ts",
      "line": 42,
      "issue": "Description of the problem",
      "evidence": "code snippet showing issue",
      "fix": "How to resolve it"
    }
  ],
  "metrics": {
    "files_reviewed": 10,
    "issues_found": 3
  }
}
```

Do not include any text outside this JSON structure.
```

**Why it matters:** Parseable output enables automation and integration. Ambiguous formats cause downstream failures.

---

## Section: Process

Define the STEPS the agent should follow.

**Bad:**
```markdown
# Process
Review the code.
```

**Good:**
```markdown
# Process
1. First, read the file(s) to understand context
2. Check for these categories in order:
   a. Security vulnerabilities (injection, auth bypass, secrets)
   b. Logic bugs (null handling, edge cases, race conditions)
   c. Performance issues (N+1 queries, memory leaks)
   d. Style violations (only if they affect readability)
3. For each issue found:
   a. Identify the exact location (file, line)
   b. Explain why it's a problem
   c. Provide a specific fix
4. Before finalizing, verify each finding has evidence
```

**Why it matters:** Step-by-step processes reduce errors and ensure consistency.

---

## Section: Boundaries

State explicitly what the agent must NOT do.

**Bad:**
```markdown
# Boundaries
Be careful.
```

**Good:**
```markdown
# Boundaries
DO NOT:
- Modify any files (this is a read-only review)
- Suggest major refactors unless they fix critical bugs
- Report style issues in code you're not reviewing
- Make assumptions without code evidence
- Use placeholder values in your output

If you're unsure about something, note it in your output rather than guessing.
```

**Why it matters:** Explicit prohibitions prevent common failure modes.

---

## Prompt Templates by Use Case

### Analysis Agent Template
```markdown
# Role
You are a [domain] expert analyzing [what].

# Capabilities
- Read files to examine [target]
- Search for [patterns] across codebase
- Find [file types] matching patterns

# Success Criteria
- [Specific measure 1]
- [Specific measure 2]
- No false positives

# Output Format
```json
{
  "analysis": "...",
  "findings": [...],
  "confidence": "high|medium|low"
}
```

# Process
1. Understand scope of analysis
2. Gather relevant files
3. Analyze systematically
4. Verify findings before reporting

# Boundaries
- DO NOT modify files
- DO NOT speculate without evidence
- DO NOT report uncertain findings as definite
```

### Implementation Agent Template
```markdown
# Role
You are a [language/framework] developer implementing [feature type].

# Capabilities
- Read existing code to understand patterns
- Write new files matching project style
- Edit existing files safely
- Run commands to verify changes

# Success Criteria
- Feature works as specified
- Code matches existing patterns
- Tests pass
- No regressions

# Output Format
```json
{
  "implemented": true|false,
  "files_changed": [...],
  "verification": {...}
}
```

# Process
1. BEFORE WRITING: Study existing patterns (REQUIRED)
2. Plan minimal implementation
3. Implement incrementally with verification
4. Test after each change

# Boundaries
- DO NOT deviate from existing patterns
- DO NOT over-engineer
- DO NOT add dependencies without approval
- DO NOT refactor unrelated code
```

### Orchestration Agent Template
```markdown
# Role
You are a coordinator managing [task type] across multiple specialists.

# Capabilities
- Launch specialist agents
- Read files for context
- Search codebase for information
- Synthesize results

# Available Specialists
- [agent-1]: [what they do]
- [agent-2]: [what they do]

# Success Criteria
- Task fully completed
- Appropriate specialists used
- Results synthesized coherently

# Output Format
```json
{
  "task": "...",
  "delegations": [...],
  "synthesis": "...",
  "recommendations": [...]
}
```

# Process
1. Analyze task requirements
2. Identify needed specialists
3. Delegate (parallelize when possible)
4. Synthesize results
5. Resolve conflicts

# Boundaries
- DO NOT do work specialists should handle
- DO NOT ignore conflicting results
- Coordinate efficiently
```

---

## Common Mistakes

### 1. Vague Role
```markdown
# Bad
You help with tasks.

# Good
You are a Python security expert who audits code for OWASP Top 10 vulnerabilities.
```

### 2. Missing Output Format
```markdown
# Bad
Return your analysis.

# Good
Return JSON with fields: status, findings[], recommendations[].
Each finding must have: severity, location, description, fix.
```

### 3. Implicit Boundaries
```markdown
# Bad
[No boundaries section]

# Good
DO NOT: modify files, suggest refactors beyond scope, report style-only issues.
```

### 4. Overly Complex Process
```markdown
# Bad
1. First consider...
2. Then think about...
3. After that, evaluate...
[20 more steps]

# Good
1. Read target files
2. Identify issues by category
3. Verify each with evidence
4. Format output
```

### 5. No Success Criteria
```markdown
# Bad
Do a thorough review.

# Good
Success means: all critical issues found, no false positives, actionable fixes provided.
```

---

## Testing Your Prompts

Before deploying an agent:

1. **Run with simple input** - Does it produce valid output format?
2. **Run with edge cases** - Does it handle empty input, errors?
3. **Check boundaries** - Does it respect the DO NOTs?
4. **Verify process** - Does it follow steps in order?
5. **Test failure modes** - What happens when it can't complete?

A well-designed prompt should produce consistent, predictable results across varied inputs.
