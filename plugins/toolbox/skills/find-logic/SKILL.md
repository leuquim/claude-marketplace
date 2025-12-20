---
name: find-logic
description: Find specific code logic - conditions, feature flags, control flow, business rules. Use for "where does X happen", "what controls Y", "how does Z work" questions. Supports two modes - pure grep (always) and hybrid vector+grep (when workspace indexed).
---

# Find Logic

Locate specific code logic in a codebase. Return file path, line number, and the actual code.

## Pre-Flight: Check Vector Search Availability

Run once at start:
```bash
code-vector-cli stats 2>&1
```

- If output shows `Total: X points` where X > 0 → Vector search available
- If error or 0 points → Vector search unavailable, use grep only

## Step 1: Classify Query

Read the user's question. Classify into ONE type:

| Type | Pattern | Example |
|------|---------|---------|
| CONCEPTUAL | "what/how/why does X" | "How does duplicate checking work?" |
| TECHNICAL | Contains class/function hint | "Where is booking validation?" |
| EXACT | Has specific name | "Find checkDuplicateAppointment" |

## Step 2: Execute Search

### If Vector Available

**CONCEPTUAL query:**
```bash
code-vector-cli search "{query}" -n 5 -t 0.3
```

**TECHNICAL query:**
```bash
code-vector-cli search-hybrid "{query}" -n 5 -t 0.05 --bm25-weight 0.7 --semantic-weight 0.3
```

**EXACT query:** Skip vector, go directly to grep.

After vector search:
- Score > 0.5 → High confidence, grep within top result
- Score 0.3-0.5 → Medium confidence, grep within top 3 results
- Score < 0.3 → Low confidence, fall back to pure grep

### If Vector Unavailable (or EXACT query)

Use grep. See [references/grep-strategies.md](references/grep-strategies.md).

## Step 3: Pinpoint with Grep

Once you have candidate files from vector search, grep within them:

```
Grep pattern: "{function_or_keyword}"
path: "{candidate_file}"
-C: 5
output_mode: "content"
```

## Step 4: Verify Answer

Before reporting, confirm you have ALL of:
1. File path: ___
2. Line number: ___
3. Actual code: ___
4. What it does: ___

If missing any, continue searching. If 4+ calls with no progress, give up.

## Step 5: Report

**If found:**
```
## Answer
[One sentence: what the logic does]

## Location
- File: [path]:[line]
- Code: `[the actual code]`

## How It Works
[2-3 sentences]
```

**If not found:**
```
## Answer
The specific logic was not found.

## What I Found Instead
[Closest related code, if any]

## Possible Explanations
- May not be implemented
- May use different terminology
```

## Limits

- Maximum 6 tool calls
- Give up after 4 calls with no progress
- Zero duplicate calls
- Stop on first complete answer
