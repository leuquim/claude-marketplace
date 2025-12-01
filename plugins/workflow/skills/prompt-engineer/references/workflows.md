# Workflow Prompt Patterns

Patterns for prompts that guide multi-step processes.

## Sequential Workflow

Use when steps must execute in order.

```
Process:
1. [First step] - [what it produces]
2. [Second step] - [what it produces]
3. [Third step] - [final output]

Complete each step before proceeding to the next.
```

## Conditional Workflow

Use when path depends on input or intermediate results.

```
Workflow:
1. Assess [condition]
2. If [condition A]: proceed to Step 3A
   If [condition B]: proceed to Step 3B
3A. [Path A steps]
3B. [Path B steps]
4. [Convergent step]
```

## Iterative Workflow

Use when refinement cycles are needed.

```
Process:
1. Generate initial [output]
2. Evaluate against [criteria]
3. If criteria not met: identify gaps and return to step 1
4. If criteria met: finalize output
```

## Parallel-Then-Merge

Use when independent subtasks feed into synthesis.

```
Execute in parallel:
- [Subtask A]: produce [output A]
- [Subtask B]: produce [output B]
- [Subtask C]: produce [output C]

Then synthesize outputs A, B, C into final [deliverable].
```

## Decision Tree

Use for complex conditional logic.

```
Decision flow:
├─ Is [condition 1]?
│  ├─ Yes → [Action 1]
│  └─ No → Check [condition 2]
│     ├─ Yes → [Action 2]
│     └─ No → [Default action]
```

## Reflection Pattern

Use when quality depends on self-evaluation. Effective for agentic prompts.

```
After completing [task]:
1. Review the output against [criteria]
2. Identify any gaps or issues
3. If issues found: address them before finalizing
4. State confidence level in final output
```

## Checkpoint Pattern

Use for long processes where early validation prevents wasted work.

```
Checkpoint 1: After [early step], verify [condition] before continuing.
Checkpoint 2: After [middle step], confirm [requirement] is satisfied.
Checkpoint 3: Before finalizing, validate [final criteria].

If any checkpoint fails, stop and report the issue.
```

## Escalation Pattern

Use when different complexity levels need different handling.

```
Assess complexity:
- Simple (criteria: [X]): Handle directly with [approach A]
- Moderate (criteria: [Y]): Apply [approach B]
- Complex (criteria: [Z]): [Escalation behavior - e.g., ask for clarification, break into subtasks]
```
