---
description: Lead-developer code review on the current branch with parallel specialists and verification
allowed-tools: Bash(git:*), Bash(cat:*), Bash(mkdir:*), Bash(ls:*), Bash(grep:*), Bash(echo:*), Read, Write, Edit, Glob, Grep, Task, AskUserQuestion
argument-hint: ""
---

Perform a lead-developer code review on the currently checked-out branch against the configured base branch.

Read the plugin's `CLAUDE.md` (in the same plugin directory as this command) for full design notes, thresholds, and pipeline rationale. The steps below are the exact pipeline; follow them precisely.

## Step 1 -- Pre-flight gates

Run these checks in order. Exit at the first failure with the exact message given.

1.1. Confirm the working directory is a git repository. Run `git rev-parse --git-dir`. If it fails, exit with: `/review: not a git repository`.

1.2. Read `.claude/review.json`. If the file does not exist or is empty, exit with: `/review: missing .claude/review.json (expected: {"baseBranch": "<branch-name>"})`.

1.3. Parse the JSON and read the `baseBranch` field. If missing, empty, or not a string, exit with the same missing-config message.

1.4. Check working tree is clean: `git status --porcelain`. If the output is non-empty, exit with: `/review: working tree has uncommitted changes; commit or stash first`.

1.5. Resolve current branch: `git branch --show-current`. Capture as `BRANCH`. If empty (detached HEAD), exit with: `/review: HEAD is detached; check out a branch first`.

1.6. If `BRANCH` equals `baseBranch`, exit with: `/review: cannot review base branch against itself`.

1.7. Targeted fetch: `git fetch origin <baseBranch> 2>&1`. If it fails, print a one-line warning (`warning: git fetch origin <baseBranch> failed; continuing with local refs`) and continue.

1.8. Resolve base ref. Prefer `origin/<baseBranch>` when it exists. Run `git rev-parse --verify origin/<baseBranch>` first; fall back to `git rev-parse --verify <baseBranch>`. Capture the resolved ref name (e.g., `origin/main` or `main`) as `BASE_REF`. If neither exists, exit with: `/review: base branch <baseBranch> not found locally or on origin`.

1.9. Check the diff is non-empty: `git diff --quiet <BASE_REF>...HEAD`. If exit code is 0 (no diff), exit with: `/review: nothing to review (HEAD matches <BASE_REF>)`.

1.10. Print the header line and continue:
```
Reviewing <BRANCH> against <BASE_REF> (<N> commits, <M> lines changed, <K> files)
```
Compute `N` with `git rev-list --count <BASE_REF>..HEAD`, `M` with `git diff --shortstat <BASE_REF>...HEAD`, `K` with `git diff --name-only <BASE_REF>...HEAD | wc -l`.

## Step 2 -- Generate diff artifact

2.1. Compute `SLUG` from `BRANCH` by replacing `/` with `-` (e.g., `feat/payment-retry` -> `feat-payment-retry`).

2.2. Compute `TIMESTAMP` as `YYYYMMDD-HHMM` in UTC (e.g., `20260413-1420`).

2.3. Ensure `.claude/reviews/` exists: `mkdir -p .claude/reviews`.

2.4. Check `.gitignore` at repo root. If it does not contain a line matching `.claude/reviews/` (exact or via glob), append `.claude/reviews/` to `.gitignore`. If `.gitignore` does not exist at the repo root, create it with that single line.

2.5. Write the diff: `git diff <BASE_REF>...HEAD > .claude/reviews/<SLUG>-<TIMESTAMP>.diff`. Capture this path as `DIFF_PATH`.

## Step 3 -- Detect prior review

3.1. Glob `.claude/reviews/<SLUG>-*.state.json` for prior state files from earlier reviews on the same branch. Exclude the current timestamp.

3.2. If any exist, pick the most recent (lexicographic sort on the filename; timestamps sort correctly). Capture as `PRIOR_STATE_PATH`.

3.3. If `PRIOR_STATE_PATH` exists:
   - Read it. Capture the stored `findings` array as `PRIOR_FINDINGS`.
   - Capture the stored `baseSha` and `headSha` as `PRIOR_BASE_SHA` and `PRIOR_HEAD_SHA`.
   - Run `git rev-parse <BASE_REF>` and `git rev-parse HEAD` to get current SHAs.
   - Run `git range-diff <PRIOR_BASE_SHA>...<PRIOR_HEAD_SHA> <BASE_REF>...HEAD 2>&1 | head -40`. Capture as `RANGE_DIFF_SUMMARY`.
3.4. Otherwise, `PRIOR_FINDINGS` is `[]` and `RANGE_DIFF_SUMMARY` is empty.

## Step 4 -- Summarize the diff

Use a Haiku agent to produce a short summary of the change.

Launch the agent with this exact prompt (substitute `<DIFF_PATH>`):

```
Read the diff at <DIFF_PATH>. Return a prose summary of the change in 3 to 6 sentences. Cover: what changed at the module/behavior level, likely intent based on commit messages visible in the diff header, and any notable refactors. Do not list every file. Do not produce bullet points. Return the summary text only, no preamble.
```

Capture the returned text as `DIFF_SUMMARY`.

## Step 5 -- Detect tests in touched paths

5.1. Extract touched file list: `git diff --name-only <BASE_REF>...HEAD`.

5.2. Detect tests via glob patterns and directory checks:
   - For each touched file, check if the diff itself adds or modifies a file matching `*.test.*`, `*_test.*`, `*.spec.*`, or under `tests/` / `__tests__/` / `test/` directories at any depth.
   - Also check for sibling test files: for each touched non-test file, glob for a test file in the same directory or nearby `tests/` sibling with a matching basename.

5.3. Set `TESTS_DETECTED` to `true` if any of the above match, else `false`.

## Step 6 -- Fire four specialist detectors in parallel

IMPORTANT: Spawn ALL FOUR Task calls in a SINGLE message. Do not spawn them sequentially. Parallelism is essential for latency.

Each Task invocation uses:
- `subagent_type`: one of `design-detect`, `correctness-detect`, `security-detect`, `tests-detect`
- `description`: short label like `design review`, `correctness review`, etc.
- `prompt`: the inputs block below, tailored per specialist

Prompt template (substitute per agent):

```
DIFF_PATH: <absolute path to DIFF_PATH>
DIFF_SUMMARY: <DIFF_SUMMARY>
REPO_ROOT: <absolute path to repo root>
TESTS_DETECTED: <true|false>  (include only for tests-detect)
PRIOR_FINDINGS: <PRIOR_FINDINGS JSON, or []>

Follow the instructions in your agent definition. Return JSON only.
```

Wait for all four agents to return. Each returns a JSON object with a `findings` array. Parse each. Flatten into a single `ALL_FINDINGS` array, assigning each finding an `id` (sequential: `f1`, `f2`, ...) and an `agreedBy` array containing the specialist's short name (`design`, `correctness`, `security`, `tests`).

## Step 7 -- Verification stage

Determine `VERIFICATION_INPUT`:

- If `TESTS_DETECTED` is `true`, set `VERIFICATION_INPUT` to `skip`. The `tests-detect` specialist already reviewed existing tests; no user prompt is needed.
- If `TESTS_DETECTED` is `false`, use `AskUserQuestion` to prompt the user with this exact question:
  ```
  No tests detected in touched paths. How should this change be verified?
  Provide a command or script to run, describe manual verification steps, or type 'skip'.
  ```
  Capture the user's response as `VERIFICATION_INPUT`. If the user types the literal word `skip` (case-insensitive), normalize to `skip`.

Spawn the `verification` agent with this prompt:

```
FINDINGS: <ALL_FINDINGS as JSON>
VERIFICATION_INPUT: <VERIFICATION_INPUT>
DIFF_PATH: <absolute path to DIFF_PATH>
REPO_ROOT: <absolute path to repo root>

Follow the instructions in your agent definition. Return JSON only.
```

Wait for the agent to return. The response contains:
- `annotatedFindings` -- the same findings, possibly with `verificationAnnotation` added
- `syntheticFindings` -- zero or more new findings (command failure, insufficient verification)
- `commandRun` -- metadata about the command, if one ran

Append `syntheticFindings` to `ALL_FINDINGS`, giving them sequential `id` values. Update `ALL_FINDINGS` with the annotations from `annotatedFindings`.

Capture `commandRun` as `VERIFICATION_META` for the final output header.

## Step 8 -- Per-issue confidence scoring

IMPORTANT: Spawn one Haiku Task per finding, ALL IN A SINGLE MESSAGE for parallelism.

For each finding in `ALL_FINDINGS`, launch a Task with:
- `subagent_type`: `general-purpose`
- `description`: `score finding <id>`
- `prompt`: the following block, with the finding JSON and diff path substituted

Scorer prompt (give verbatim to each Haiku agent):

```
You are scoring a single code review finding for confidence that it is a real issue, not a false positive.

FINDING: <finding JSON>
DIFF_PATH: <absolute path to DIFF_PATH>

Read the diff. Read any relevant source files in the repo. Then score the finding on this scale:

0: Not confident at all. This is a false positive that does not stand up to light scrutiny, or is a pre-existing issue.
25: Somewhat confident. This might be a real issue, but may also be a false positive. You were not able to verify that it is a real issue.
50: Moderately confident. You verified this is a real issue, but it might be a nitpick or not happen often in practice. Relative to the rest of the PR, it is not very important.
75: Highly confident. You double-checked the issue and verified that it is very likely to be hit in practice. The existing approach is insufficient. The issue is important and will directly impact functionality.
100: Absolutely certain. You double-checked and confirmed it is definitely a real issue, will happen frequently, and the evidence directly confirms.

If the finding has a verificationAnnotation of "corroborated", add 25 to your score (cap at 100). If it has "refuted", score 0.

Return JSON only, no prose:
{"id": "<finding id>", "confidence": <integer 0-100>}
```

Parse each scorer's response. Attach `confidence` to the corresponding finding in `ALL_FINDINGS`.

## Step 9 -- Filter by severity-dependent thresholds

For each finding, drop it if:
- `severity` is `blocking` or `important` and `confidence < 50`
- `severity` is `nit` or `suggestion` and `confidence < 80`
- `severity` is `praise` and `confidence < 70`

Keep track of how many were dropped -- the final footer reports the count.

## Step 10 -- Semantic dedup

Group findings that refer to the same underlying issue:
- Same `file`
- Overlapping line ranges (`startLine`-`endLine` intersect or are within 5 lines of each other)
- Similar `title` (substantial word overlap)

Collapse each group to a single finding:
- Keep the highest `confidence`
- Use the most severe `severity` (order: blocking > important > suggestion > nit > praise)
- Use the title from the highest-confidence member
- Merge `rationale`: keep the highest-confidence one; if others add distinct detail, append in a second sentence
- Union the `agreedBy` arrays -- this is the signal that multiple specialists converged

## Step 11 -- Tag prior-review status

If `PRIOR_FINDINGS` is non-empty, for each current finding:
- Find the best prior match by (file, line proximity within 10 lines, similar title).
- If a match exists, tag `priorStatus: "unresolved"`.
- If no match, tag `priorStatus: "new"`.

Separately, for each prior finding with no current match, track it as `resolved`. Count these for the output header. Do not add them to `ALL_FINDINGS`.

## Step 12 -- Compute verdict

Apply these rules in order:

- If any remaining finding has `severity` `blocking` or `important`: `VERDICT = "request-changes"`.
- Else if any has `severity` `nit` or `suggestion`: `VERDICT = "approve-with-nits"`.
- Else: `VERDICT = "approve"`.

Compute `VERDICT_REASON` as one short sentence:
- `request-changes`: `<N> blocking and <M> important findings` (omit a half if zero)
- `approve-with-nits`: `<N> nits and <M> suggestions`
- `approve`: `no findings above threshold`

## Step 13 -- Render compact output

Produce a Markdown document with this exact structure. Write to `.claude/reviews/<SLUG>-<TIMESTAMP>.md` AND print the same content to stdout.

```markdown
# Review: <BRANCH> vs <BASE_REF>

<N> commits, <M> lines changed, <K> files
Verdict: **<VERDICT>** -- <VERDICT_REASON>
Verification: <one-line verification summary, see below>
<if RANGE_DIFF_SUMMARY non-empty:>
Since last review: <short description, e.g. "3 new commits, 2 files changed; 1 prior finding resolved, 2 unresolved">
</if>

## Blocking (<count>)

<one block per finding, see finding format below>

## Important (<count>)

<blocks>

## Suggestions (<count>)

<blocks>

## Nits (<count>)

<blocks>

## Praise (<count>)

<blocks>

---

Reviewed in <elapsed seconds>s. Specialists: design, correctness, security, tests.
Filtered <dropped_count> low-confidence findings.

Files:
  .claude/reviews/<SLUG>-<TIMESTAMP>.md
  .claude/reviews/<SLUG>-<TIMESTAMP>.diff
```

Finding block format (compact, single-line-ish):

```
[<severity> - <confidence> - <agreedBy joined by +>] <file>:<startLine>-<endLine> -- <title>
  Why: <rationale>
  Fix: <suggestedFix, omit line if field absent>
  Evidence: <verificationAnnotation.evidence, omit line if absent>
  Prior: <priorStatus, omit line if "new" or absent>
```

Skip severity sections with zero findings entirely (do not print an empty "## Praise (0)" header).

Verification summary line options:
- If `VERIFICATION_META.command` is set and `exitCode == 0`: `Verification: ran \`<command>\` -- passed in <duration>s`
- If set and `exitCode != 0`: `Verification: ran \`<command>\` -- FAILED (exit <code>)`
- If `VERIFICATION_INPUT == "skip"` and `TESTS_DETECTED == true`: `Verification: existing tests reviewed by tests-detect`
- If `VERIFICATION_INPUT == "skip"` and `TESTS_DETECTED == false`: `Verification: skipped by user`
- If verification was manual-steps prose: `Verification: manual steps reviewed (see findings if insufficient)`

## Step 14 -- Persist state

Write `.claude/reviews/<SLUG>-<TIMESTAMP>.state.json` with this shape. This is internal state for the next re-review; format is not a public contract.

```json
{
  "schemaVersion": "0.1",
  "branch": "<BRANCH>",
  "base": "<baseBranch from config>",
  "baseRef": "<BASE_REF>",
  "baseSha": "<git rev-parse BASE_REF output>",
  "headSha": "<git rev-parse HEAD output>",
  "timestamp": "<ISO8601 UTC>",
  "verdict": "<VERDICT>",
  "verification": { ...VERIFICATION_META or null... },
  "findings": [ ...ALL_FINDINGS after filtering, dedup, and tagging... ]
}
```

## Step 15 -- Offer rich doc

If `VERDICT` is `request-changes` or any remaining finding has `severity` `important`, use `AskUserQuestion` to prompt:

```
Run /review-doc to produce the navigable doc? [y/N]
```

If the user answers affirmatively (y, yes, Y, etc.), invoke the `review-doc` skill. Findings are in conversation context; the skill reads them from there. When invoking, inform it of the severity-to-P-tier mapping: `blocking` -> P0, `important` -> P1, `nit` and `suggestion` -> P2, `praise` -> What's Good.

If the user declines or the verdict is `approve` / `approve-with-nits`, do not prompt.

## False positive list (applies to all specialists and scorers)

Treat these as NOT findings. If a specialist flagged one, the scorer should rate it 0.

- Pre-existing issues not introduced in this diff
- Issues on lines the diff did not modify (unless the diff's change materially breaks them)
- Style, formatting, and import-order issues (linter territory)
- Type errors, missing imports, syntax errors (typechecker and compiler territory, CI runs these)
- Pedantic nitpicks a senior engineer would not raise in review
- Issues called out in code with an explicit suppression comment, unless the suppression is clearly wrong
- Changes in functionality that are clearly intentional given the PR's stated intent
- "Could have more tests" as a general observation

## Notes

- Use `gh` / `glab` only if a future version needs MR integration; v0.1 is local-only.
- Do not attempt to build, typecheck, or run the project. Assume CI handles those.
- Make a todo list before Step 1 so the user can track the pipeline.
- Every finding must cite a concrete file and line range. Findings without both are invalid.
