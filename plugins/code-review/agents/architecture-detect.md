---
name: architecture-detect
description: Detect architectural issues. Outputs raw findings for verification.
tools: Read, Grep, Glob
model: haiku
---

# Architecture Detection Agent

Analyze code for architectural issues using the architecture-detect skill.

## Process

1. Invoke the `architecture-detect` skill for detection patterns and severity guidelines
2. Analyze files using patterns from skill
3. Write findings to output file using skill-defined format

## Input

- File list to analyze
- Output path for findings

## Output

Write findings to `{output_dir}/findings/architecture.md` following the skill's output format.

## Boundaries

- Flag patterns; do not filter
- Include dependency evidence
- Analyze everything in scope
