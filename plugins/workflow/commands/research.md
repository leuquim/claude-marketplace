---
description: Research codebase for a defined feature. Runs three parallel agents (Explore + vector search + repo analyst) to find affected files, patterns, compounded knowledge, and dependencies. Requires existing definition.
allowed-tools: Read, Write, Glob, Task
---

## Task

Research the codebase for an already-defined feature. This is Phase 2 of the development workflow.

## Prerequisites

This command requires an active work item with a definition. The conversation should already have context about which feature is being worked on.

## Process

### 1. Locate the Definition

Find the definition file for the current work item in `.docs/work/{slug}/definition.md`.

If no definition exists or the work item is unclear, stop and ask the user to run `/define` first or clarify which feature to research.

### 2. Read the Definition

Read the definition file to understand:
- What problem is being solved
- Goals and non-goals
- Constraints
- Acceptance criteria

### 3. Run Parallel Research

Launch THREE agents in parallel using the Task tool in a single message:

**Agent 1: Explore (built-in)**
```
Prompt: Research the codebase for implementing this feature:

{paste definition content}

Find:
1. Files that will need modification
2. Existing patterns and conventions to follow
3. Related functionality to understand
4. Dependencies and integrations
5. Test patterns used in similar areas

Return structured findings with file paths and explanations.
```

**Agent 2: vector-research (custom)**
```
Prompt: Research the codebase using semantic search for this feature:

{paste definition content}

Use code-vector-cli to find relevant code, similar implementations, potential impact areas, and historical context.

Note: If the project is not indexed, report that and skip vector search.
```

**Agent 3: repo-analyst (custom)**
```
Prompt: Research existing documentation and compounded knowledge for this feature:

{paste definition content}

Search:
1. .docs/learnings/ for relevant compounded knowledge
2. CLAUDE.md, README.md, ARCHITECTURE.md for project context
3. Existing patterns and conventions in documentation

Return findings with specific file paths and key insights.
```

### 4. Synthesize Findings

Combine results from all three agents into a unified research document:
- Merge file lists (deduplicate)
- Combine pattern observations
- Prioritize compounded learnings (team knowledge)
- Note any conflicts between sources

### 5. Write Research Output

Create `.docs/work/{slug}/research.md`:

```markdown
# Research: {Feature Title}

> Research findings for {slug}

## Compounded Knowledge

{Relevant learnings from .docs/learnings/ - this is team wisdom}

- **{learning-title}** (`.docs/learnings/{domain}/{file}.md`)
  > {key insight}

## Affected Files

### Files to Modify
- `path/to/file.js` - {what changes needed}

### Files to Create
- `path/to/new-file.js` - {purpose}

## Existing Patterns

{Patterns discovered that should be followed}

### Code Style
- {Observation about code style}

### Architecture
- {Observation about architecture patterns}

### Testing
- {How similar features are tested}

## Dependencies

### Internal
- `module/name` - {how it relates}

### External
- `package-name` - {if new dependencies needed}

## Similar Implementations

Reference implementations to follow:
- `path/to/reference.js` - {what to learn from it}

## Project Context

{Relevant info from CLAUDE.md, README, ARCHITECTURE}

## Potential Risks

- {Risk 1}
- {Risk 2}

## Open Questions

- {Question that needs clarification before implementation}

## Recommendations

1. {Recommendation from compounded knowledge}
2. {Pattern to follow from codebase}
3. {Approach based on findings}
```

### 6. Summarize for User

After writing, provide a brief summary of:
- Key compounded learnings found (if any)
- Files to be modified
- Patterns to follow
- Open questions needing resolution before planning

## Rules

- MUST have a definition before researching
- MUST run all three agents in parallel (single Task tool message with three calls)
- PRIORITIZE compounded learnings - this is captured team knowledge
- Include file paths in all findings
- Flag conflicts between agent findings
- Note if vector search index is missing or stale
- Keep research focused on the defined scope
