# review

Lead-developer code review on the current branch. Runs four parallel specialists (design, correctness, security, tests), corroborates findings against a user-supplied verification command, scores each finding for confidence, and renders a severity-graded report.

## Usage

```
/review
```

Reviews `git diff <baseBranch>...HEAD` where `<baseBranch>` comes from `.claude/review.json` in the repo root.

## Setup

Create `.claude/review.json` in the repo:

```json
{
  "baseBranch": "main"
}
```

Without this file, `/review` exits early.

## What it does

1. Pre-flight gates: clean working tree, base branch reachable, diff non-empty.
2. Generates `git diff <base>...HEAD` and saves to `.claude/reviews/<branch>-<timestamp>.diff`.
3. If a prior review exists for the same branch, runs `git range-diff` to surface what changed.
4. Spawns four specialists in parallel (Sonnet): design, correctness, security, tests.
5. Verification stage: when no tests are detected in touched paths, prompts for a verification command. Runs it. Annotates each finding as corroborated, refuted, untestable, or unverified.
6. Per-issue Haiku scorers rate confidence 0-100. Severity-dependent thresholds filter noise.
7. Semantic dedup preserves which specialists agreed.
8. Renders compact Markdown to stdout and `.claude/reviews/<branch>-<timestamp>.md`.
9. Persists internal state (`.state.json`) for the next re-review.
10. If findings include any blocking or important, offers to invoke `/review-doc` for the rich PhpStorm-navigable document.

## Output

Three files per invocation in `.claude/reviews/`:

- `<branch>-<timestamp>.md` -- compact terminal output
- `<branch>-<timestamp>.diff` -- raw git diff (IDE-navigable)
- `<branch>-<timestamp>.state.json` -- internal state for re-review delta (do not depend on format)

`.claude/reviews/` is gitignored on first invocation.

## Composition

Pairs with the `review-doc` skill for rich PhpStorm-friendly output. `/review` produces compact terminal results; `/review-doc` formats them into the full Brief + P0/P1/P2 + colored-diff document when invoked.

## Verdict

- `approve` -- no findings above threshold
- `approve-with-nits` -- only nits or suggestions
- `request-changes` -- any blocking or important finding
