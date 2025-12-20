# Vector Search Strategies

Use when `code-vector-cli stats` shows indexed points > 0.

## Command Reference

### Semantic Search (CONCEPTUAL queries)
```bash
code-vector-cli search "{natural language query}" -n 5 -t 0.3
```
Best for: "what controls X", "how does Y work"

### Hybrid Search (TECHNICAL queries)
```bash
code-vector-cli search-hybrid "{query with class/function hints}" -n 5 -t 0.05 --bm25-weight 0.7 --semantic-weight 0.3
```
Best for: queries mentioning specific components

### Hybrid Keyword-Heavy (near-EXACT queries)
```bash
code-vector-cli search-hybrid "{exact terms}" -n 5 -t 0.01 --bm25-weight 0.9 --semantic-weight 0.1
```
Best for: when you know partial names

## Parameter Tuning

| Parameter | Low Value | High Value |
|-----------|-----------|------------|
| `-t` threshold | 0.01-0.1 (more results) | 0.3-0.5 (fewer, precise) |
| `--bm25-weight` | 0.2 (meaning-based) | 0.8 (keyword-based) |
| `-n` limit | 3 (focused) | 10 (exploratory) |

## Score Interpretation

| Score | Confidence | Action |
|-------|------------|--------|
| > 0.6 | High | Use top result directly |
| 0.4-0.6 | Medium | Grep within top 3 files |
| 0.2-0.4 | Low | Grep within top 5 files |
| < 0.2 | Very low | Fall back to pure grep |

## Known Limitations

1. **Finds usage, not definitions**: May find callers instead of the actual method
2. **Large files rank lower**: Functions in 3000+ line files may be missed
3. **Typos break matching**: `Appoinment` won't match `Appointment`
4. **No file type filtering**: Can't restrict to "only PHP" or "only mobile"

## When to Skip Vector Search

- Query has exact function/class name → Use grep directly
- Query mentions specific file path → Use grep directly
- Previous vector search scored < 0.2 → Don't retry, use grep
