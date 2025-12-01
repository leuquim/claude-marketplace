---
description: Initialize project-specific agents optimized for your tech stack.
allowed-tools: Read, Glob, Grep, Task, AskUserQuestion, Write
---

## Task

Discover the project's tech stack and create specialized agents that optimize Claude's work on this specific project.

## Process

### 1. Stack Discovery

Launch the `stack-discovery` agent to analyze the project:

```
Explore this project and identify:
1. Languages and versions
2. Frameworks and versions
3. Key libraries that affect code patterns
4. Tooling (test runners, build tools)
5. Stack combinations that would benefit from specialized agents

Return a structured Stack Discovery Report.
```

### 2. User Input

After receiving the stack report, use AskUserQuestion with multi-select:

**Question:** "Based on your project, I can create specialized agents for:"

**Options:** (dynamically generated from stack discovery)
- {Stack combo 1 from report} - {brief rationale}
- {Stack combo 2 from report} - {brief rationale}
- {Stack combo N from report} - {brief rationale}

**Multi-select:** true

**Free text prompt:** "Any other agents you want? (e.g., 'Redis caching patterns', 'GraphQL subscriptions')"

### 3. Check Existing Project Agents

Before generating, check for existing project agents:

```bash
# Check for existing .claude/agents/
```

If found:
- List existing agents
- Note which will be updated vs created new
- Preserve agents not being modified

### 4. Generate Agents

For each selected stack combo (from user selection + custom requests):

**Step 4a: Load Skills**

Reference these skills for high-quality generation:
- `agent-builder` skill - for agent structure and tool selection
- `prompt-engineer` skill - for effective prompts

**Step 4b: Design Each Agent**

For each agent, determine:

1. **Name:** `{stack}-agent.md` (e.g., `laravel10-livewire-agent.md`)

2. **Tools:** Based on agent purpose
   - Work mode needs: Read, Write, Edit, Grep, Glob, Bash
   - Review mode needs: Read, Grep, Glob
   - Dual-use: Read, Write, Edit, Grep, Glob, Bash

3. **Prompt Structure:**
```markdown
---
name: {stack-name}
description: {Stack} development and review. Use when implementing features, reviewing code, or answering questions about this stack.
tools: Read, Write, Edit, Grep, Glob, Bash
---

# {Stack Name} Agent

Specialized agent for {stack} development.

## Capabilities

### Work Mode
When implementing features:
- {Framework-specific implementation patterns}
- {Common architectural approaches}
- {Best practices for this stack}

### Review Mode
When reviewing code:
- {Framework-specific anti-patterns to catch}
- {Version-specific gotchas}
- {Performance considerations for this stack}

## Framework Knowledge

### Core Patterns
{Key patterns and idioms for this framework/stack}

### Common Pitfalls
{What to avoid, version-specific issues}

### Best Practices
{Recommended approaches for this stack}

## Version-Specific Notes
{Important differences in this version vs previous}
```

**Step 4c: Apply prompt-engineer Principles**

- Use imperative form
- Provide rationale for constraints
- Be explicit, not implicit
- Avoid aggressive language (no MUST, NEVER in caps)
- Include concrete examples where helpful

### 5. Present for Review

Before creating any files, present all proposed agents:

```markdown
## Proposed Project Agents

### 1. {agent-name}
**File:** `.claude/agents/{name}.md`
**Purpose:** {description}
**Tools:** {tool list}

<details>
<summary>Preview content</summary>

{Full agent content}

</details>

---

### 2. {agent-name}
...
```

Then ask:

**Question:** "Review the proposed agents. What would you like to do?"

**Options:**
- Create all agents as shown
- Let me modify some before creating
- Cancel - don't create any

### 6. Create Files

After user approval:

**6a: Create directory if needed**
```
.claude/agents/
```

**6b: Write each approved agent file**

**6c: Update CLAUDE.md**

Add or update "Project Tools" section:

```markdown
## Project Tools

Project-specific agents optimized for this tech stack. These are used automatically by `/work` and `/review` commands.

### Agents

| Agent | Stack | Use When |
|-------|-------|----------|
| {name} | {stack} | {trigger conditions} |

Location: `.claude/agents/`
```

### 7. Summary

Report what was created:

```markdown
## Workflow Init Complete

### Created Agents
- `.claude/agents/{name}.md` - {purpose}
- `.claude/agents/{name}.md` - {purpose}

### Updated
- `CLAUDE.md` - Added Project Tools section

### Next Steps
- `/work` and `/review` will now use these agents automatically
- Run `/workflow-init` again to add more agents or update existing ones
- Edit agents directly in `.claude/agents/` to customize
```

## Re-run Behavior

When `/workflow-init` is run on a project with existing agents:

1. Stack discovery runs fresh
2. Compare discovered stacks with existing agents
3. Propose:
   - **New:** Stacks not yet covered
   - **Update:** Existing agents that could be improved
   - **Keep:** Existing agents still relevant
4. Never delete existing agents without explicit request

## Rules

- Always run stack discovery first, then present options
- Generate agents using agent-builder and prompt-engineer skill patterns
- All agents must support both work and review modes
- Present full preview before creating any files
- Require explicit user approval before file creation
- Preserve existing agents not being modified
- Update CLAUDE.md to document created agents
