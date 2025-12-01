---
name: agent-builder
description: Design and build effective Claude agents and subagents. Use when creating new agents, configuring multi-agent systems, writing agent prompts, or optimizing agent configurations. Helps with agent architecture, tool selection, permission modes, and system prompt design.
allowed-tools: Read, Write, Glob, Grep, AskUserQuestion
---

# Agent Builder

Build effective, optimized agents for any task using Claude Agent SDK best practices.

## Quick Reference

### Tool Sets by Task Type

| Task Type | Tools | Permission Mode |
|-----------|-------|-----------------|
| Analysis/Review | Read, Grep, Glob, WebSearch | plan |
| Testing | Bash, Read, Grep, Glob | default |
| Development | Read, Write, Edit, Bash, Grep, Glob | acceptEdits |
| Planning | Read, Grep, Glob | plan |
| Research | WebSearch, WebFetch, Read | plan |
| Orchestration | Task, Read, Grep, Glob | default |

### Model Selection

- **Haiku**: Simple, fast tasks (formatting, basic extraction)
- **Sonnet**: Most tasks (coding, analysis, testing)
- **Opus**: Complex reasoning (architecture, multi-step planning)

## Design Process

### Step 1: Gather Requirements

Use AskUserQuestion to clarify:

1. **What** will the agent do? (specific task description)
2. **How** will it execute? (one-shot, interactive, background)
3. **What** context does it need? (codebase patterns, docs, domain knowledge)
4. **What** are the safety boundaries? (files, commands, services)

### Step 2: Choose Architecture

**Single Agent** - Focused task, no parallelization needed

**Fork + Gather** - Multiple independent analyses, speed matters
```
Main Agent -> [Agent A, Agent B, Agent C] -> Synthesize
```

**Sequential Pipeline** - Tasks have dependencies
```
Analyze -> Plan -> Implement -> Verify
```

**Hierarchical** - Complex coordination, dynamic delegation
```
Orchestrator -> Specialists -> Sub-specialists
```

### Step 3: Write System Prompt

Follow this structure exactly:

```markdown
# Role
You are a [specific role] specializing in [domain].

# Capabilities
Your tools allow you to:
- [Capability 1]
- [Capability 2]

# Success Criteria
A successful outcome means:
- [Criterion 1]
- [Criterion 2]

# Output Format
Return results as:
[Exact format - JSON schema, markdown structure, etc.]

# Process
1. [Step 1]
2. [Step 2]
3. [Step 3]

# Boundaries
DO NOT:
- [Prohibited action 1]
- [Prohibited action 2]
```

## Agent Configuration Format

Output agents in this format:

**For `.claude/agents/[name].md`:**

```markdown
---
name: agent-name
description: When to invoke this agent (used for auto-selection)
tools: Tool1, Tool2, Tool3
model: sonnet
---

[System prompt content]
```

**For programmatic use:**

```typescript
{
  "agent-name": {
    description: "When to invoke this agent",
    prompt: `[System prompt]`,
    tools: ["Tool1", "Tool2"],
    model: "sonnet"
  }
}
```

## Optimization Checklist

Before finalizing any agent, verify:

- [ ] **Minimal tools** - Only what's strictly needed
- [ ] **Appropriate permissions** - Least privilege principle
- [ ] **Clear role** - Specific expertise defined
- [ ] **Exact output format** - Parseable, unambiguous
- [ ] **Explicit boundaries** - What NOT to do
- [ ] **Right model** - Matches task complexity
- [ ] **Verification step** - How to check work

## Common Pitfalls

| Pitfall | Solution |
|---------|----------|
| Over-permissioning | Start with Read, Grep, Glob only |
| Vague output format | Specify exact JSON schema |
| Missing boundaries | List what agent must NOT do |
| Monolithic design | Split into focused subagents |
| No verification | Add explicit check step in process |
| Wrong model | Use Sonnet default, Opus for complex only |

## Example Templates

See `templates.md` for complete agent templates:
- Code Reviewer
- Test Runner
- Feature Implementer
- Research Agent
- Security Auditor
