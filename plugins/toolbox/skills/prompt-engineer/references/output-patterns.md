# Output Format Patterns

Patterns for specifying desired output structure.

## Structured Data

### JSON Output

```
Respond with a JSON object:
{
  "field1": "description of field1",
  "field2": ["array", "items"],
  "field3": {
    "nested": "object"
  }
}

Include only the JSON. No markdown code fences or surrounding text.
```

### Tabular Output

```
Format as a markdown table:
| Column A | Column B | Column C |
|----------|----------|----------|
| data     | data     | data     |

Sort by [column] in [ascending/descending] order.
```

## Document Structures

### Report Format

```
Structure:
## Executive Summary
[2-3 sentences, key findings]

## Analysis
[Detailed breakdown with subsections as needed]

## Recommendations
[Prioritized action items]

## Appendix (if applicable)
[Supporting data, references]
```

### Comparison Format

```
Compare [A] and [B]:

**Similarities:**
- [point 1]
- [point 2]

**Differences:**
| Aspect | A | B |
|--------|---|---|
| [aspect] | [A's approach] | [B's approach] |

**Recommendation:** [which to choose and why]
```

### Checklist Format

```
Output as a checklist:
- [ ] Item 1: [description]
- [ ] Item 2: [description]
- [x] Item 3: [if pre-checked, why]
```

## Communication Formats

### Brief/Summary

```
Provide a brief:
- Context: [1 sentence]
- Key point: [1 sentence]
- Implication: [1 sentence]
- Action: [1 sentence]

Maximum 4 sentences total.
```

### Detailed Explanation

```
Explain [topic]:
1. What it is (definition)
2. Why it matters (relevance)
3. How it works (mechanism)
4. When to use it (application)
5. Common pitfalls (warnings)
```

## Code Output

### Code Only

```
Respond with only the code. No explanations, no markdown fences, no comments unless they're essential for understanding.
```

### Code with Context

```
Provide:
1. The code implementation
2. Brief explanation of key decisions (2-3 sentences)
3. Usage example
```

### Diff Format

```
Show changes as a diff:
- Lines to remove (prefix with -)
+ Lines to add (prefix with +)
  Unchanged context lines (no prefix)
```

## Constrained Outputs

### Length Constraints

```
Response length: [X] words maximum.
```

```
Respond in exactly [N] bullet points.
```

```
One paragraph only. No line breaks.
```

### Tone/Style Constraints

```
Tone: [professional/casual/technical/friendly]
Audience: [expert/beginner/executive/developer]
Avoid: [jargon/hedging/passive voice]
```

### Confidence Indicators

```
After your response, indicate confidence:
- HIGH: Strong evidence, well-understood domain
- MEDIUM: Reasonable inference, some uncertainty
- LOW: Limited information, significant assumptions made
```

## Negative Constraints

Specify what NOT to include:

```
Do not include:
- Preamble ("Here's the answer..." / "I'll help you...")
- Caveats or disclaimers
- Suggestions beyond what was asked
- Apologies
```

## Meta-Output Patterns

### Reasoning Visible

```
Show your reasoning:
1. [First consideration]
2. [Second consideration]
3. [Conclusion]

Then provide the final answer separately.
```

### Reasoning Hidden

```
Provide only the final answer. Do not show working or reasoning.
```

### Progressive Disclosure

```
Start with the answer/recommendation.
Then provide supporting detail.
End with caveats or edge cases (if any).
```
