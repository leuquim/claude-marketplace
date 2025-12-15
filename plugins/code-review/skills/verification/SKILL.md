---
name: verification
description: Validate code review findings through evidence-based analysis. Use when: (1) reviewing raw detection findings before final report, (2) a finding needs deeper investigation, (3) determining if an issue is a false positive. Performs lifecycle analysis, scope boundary checks, code classification, and impact assessment to filter false positives and calibrate severity.
---

# Verification Skill

Transform raw detection findings into validated, evidence-backed findings.

## Core Principle

A finding is not valid until proven. Detection identifies patterns; verification proves problems exist.

## Verification Framework

For each finding, answer these five questions:

### 1. Lifecycle Analysis

**Question:** When is this created? When is it cleaned up?

**Actions:**
- Search for cleanup/dispose/clear/close calls on the flagged resource
- Check if resource is scoped to a request/build/session lifecycle
- Look for `finally` blocks, cleanup handlers, or lifecycle hooks

**Verdict:**
- If cleanup exists within appropriate lifecycle → downgrade or filter
- If no cleanup and long-lived → validate concern

**Example:**
```
Finding: "Unbounded cache growth"
Check: grep for `.clear()`, `.dispose()`, lifecycle hooks
Result: Cache cleared after each build → FALSE POSITIVE
```

### 2. Scope Boundary Analysis

**Question:** What bounds the affected data/resources?

**Actions:**
- Trace data flow to identify natural boundaries
- Check if resources are scoped by user/tenant/request/session
- Identify maximum realistic size within scope

**Verdict:**
- If naturally bounded by scope → assess if bound is acceptable
- If truly unbounded → validate concern

**Example:**
```
Finding: "Unbounded S3 listing"
Check: Trace prefix parameter → scoped by siteId
Result: Bounded by files per site (~60K max) → DOWNGRADE to Low
```

### 3. Code Classification

**Question:** What type of code is this?

**Categories:**
| Type | Characteristics | Implications |
|------|-----------------|--------------|
| Runtime Service | Handles requests, long-running | High scrutiny |
| CLI Tool | Manual execution, scripts/ | console.log acceptable |
| Test Code | __tests__/, *.test.*, *.spec.* | Mocks/stubs expected |
| Build Script | webpack, vite, build configs | Dev-only concerns |
| Migration | Database migrations | One-time execution |

**Verdict:**
- Apply standards appropriate to code type
- CLI tools have different rules than services

**Example:**
```
Finding: "console.log usage"
Check: File location → /scripts/health-check.js
Result: CLI tool, console.log is correct → FALSE POSITIVE
```

### 4. Evidence Gathering

**Question:** What proves this is actually a problem?

**Actions:**
- Read the flagged code in full context (not just snippet)
- Check if mitigations exist elsewhere
- Look for comments explaining the pattern
- Verify assumptions with actual code paths

**Required Evidence:**
- Exact file:line reference
- Code snippet showing the issue
- Proof that no mitigation exists
- Data flow showing exploitability (for security)

**Verdict:**
- If evidence incomplete → investigate more or filter
- If evidence solid → validate with confidence level

### 5. Impact Assessment

**Question:** What's the real-world consequence?

**Factors:**
- Frequency: How often does this code path execute?
- Blast radius: What fails if this goes wrong?
- Exploitability: Can this be triggered externally?
- Data sensitivity: What data is affected?

**Severity Calibration:**
| Initial | After Assessment | Condition |
|---------|------------------|-----------|
| Critical | → High | Limited blast radius |
| Critical | → Medium | Requires internal access |
| High | → Medium | Self-correcting within cycle |
| High | → Low | Cosmetic impact only |
| Medium | → Filter | Already mitigated elsewhere |

## Output Format

For each finding, produce:

```markdown
### [Severity] Finding Title

**Original Severity:** {from detection}
**Verified Severity:** {after verification}
**Verdict:** VALIDATED | DOWNGRADED | FALSE POSITIVE

**Verification Evidence:**

1. **Lifecycle:** {analysis result}
2. **Scope:** {boundary analysis}
3. **Classification:** {code type and implications}
4. **Evidence:** {proof or lack thereof}
5. **Impact:** {real-world assessment}

**Location:** `path/to/file.ext:line`

**Conclusion:** {1-2 sentence summary of why this verdict}
```

## Batch Processing

When verifying multiple findings:

1. Group by file/module for efficient reading
2. Check for cross-finding dependencies
3. Look for patterns that indicate systematic issues vs one-offs
4. Deduplicate findings that refer to same root cause

## Verification Shortcuts

Some patterns can be quickly validated/filtered:

| Pattern | Quick Check | Likely Verdict |
|---------|-------------|----------------|
| "Unbounded X" | Search for cleanup | Often FALSE POSITIVE |
| "Missing timeout" | Check if configurable | Often DOWNGRADE |
| "Hardcoded value" | Check if documented | Context-dependent |
| "No error handling" | Check caller chain | May be intentional |
| "console.log" | Check file location | CLI = FALSE POSITIVE |

## Quality Standards

A verified finding must have:
- [ ] All five framework questions answered
- [ ] Concrete evidence (not assumptions)
- [ ] Appropriate severity for actual impact
- [ ] Clear, actionable conclusion
