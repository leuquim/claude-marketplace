# Code Vector Search - Quick Reference

## Setup Commands

```bash
# Initialize project (run once)
code-vector-cli init

# Index git history (run once)
code-vector-cli index-git

# Index conversations (run once)
code-vector-cli migrate-conversations

# Daily updates (fast!)
code-vector-cli index --incremental        # Update code index
code-vector-cli index-git --incremental    # Index new commits/merges
```

## Search Commands

```bash
# Semantic search
code-vector-cli search "concept or description" -n 10

# Hybrid (semantic + keyword)
code-vector-cli search-hybrid "ExactClassName or keyword"

# Find similar code
code-vector-cli similar path/to/file.js -n 10
code-vector-cli similar "semantic description" -t 0.7

# Get task context
code-vector-cli context "task description" -n 15

# Impact analysis
code-vector-cli impact path/to/file.js -t 0.6

# Search git history
code-vector-cli search-git "commit topic" -n 5

# Search conversations
code-vector-cli search-conversations "discussion topic" -n 5

# Search documentation
code-vector-cli search-docs "API guide" -n 5
```

## Common Flags

```bash
-n, --limit N          Number of results (default: 10)
-t, --threshold T      Similarity threshold 0-1 (default: 0.3)
--show-content         Display code snippets
--show-parent          Show parent class/module
-C, --context-lines N  Context lines around snippets (default: 3)
--json                 JSON output for scripting
```

## Threshold Guide

| Threshold | Use Case | Results |
|-----------|----------|---------|
| 0.1-0.2 | Exploratory search | Many, broad matches |
| 0.3 | Default | Balanced quality/quantity |
| 0.4-0.5 | High precision | Fewer, very relevant |
| 0.6+ | Near-exact | Only close matches |

## Hybrid Search Weights

```bash
# Default: 70% semantic, 30% keyword
code-vector-cli search-hybrid "query"

# Equal balance
code-vector-cli search-hybrid "query" --semantic-weight 0.5 --bm25-weight 0.5

# Favor keywords (good for function names)
code-vector-cli search-hybrid "getUserById" --semantic-weight 0.4 --bm25-weight 0.6
```

## Workflow Recipes

### Starting a Feature
```bash
code-vector-cli context "feature description" -n 15
code-vector-cli search "related concept" --show-content
code-vector-cli search-conversations "feature topic"
```

### Refactoring Prep
```bash
code-vector-cli impact path/to/file.js
code-vector-cli similar path/to/file.js -t 0.8
code-vector-cli search-git "related changes"
```

### Understanding Code
```bash
code-vector-cli search "concept" -n 10
code-vector-cli similar path/to/unfamiliar-file.js
code-vector-cli search-docs "architecture"
```

### Daily Development
```bash
# Morning
code-vector-cli index --incremental        # Update code
code-vector-cli index-git --incremental    # Index new commits

# As needed
code-vector-cli search "..."
code-vector-cli search-hybrid "..."

# Before commit
code-vector-cli impact path/to/modified-file.js
```

## Maintenance

```bash
# Check status
code-vector-cli stats

# List all projects
code-vector-cli list-projects -v

# Cleanup
code-vector-cli cleanup-metadata

# Delete project data
code-vector-cli delete --force

# Reindex single file
code-vector-cli reindex-file path/to/file.js
```

## Multi-Repo

```bash
# Index entire workspace
cd /workspace/root
code-vector-cli init

# Index specific repo
code-vector-cli index --repo cms

# Search (shows repo labels)
code-vector-cli search "query"
# Output: [cms] path/to/file.js
#         [builder] path/to/other.js
```

## Performance Tips

✅ **DO:**
- Use `--incremental` daily (500x faster)
- Start with broad search, narrow with higher threshold
- Use `search-hybrid` for exact terms
- Limit results with `-n 5` when skimming

❌ **DON'T:**
- Skip incremental indexing
- Use for exact string matching (use grep)
- Index node_modules or build artifacts
- Forget to reindex after branch switches

## Troubleshooting

### No results
```bash
code-vector-cli stats              # Verify indexed
code-vector-cli search "..." -t 0.1  # Lower threshold
code-vector-cli search-hybrid "..."  # Try hybrid
```

### Stale results
```bash
code-vector-cli index --incremental  # Quick update
```

### Wrong project
```bash
cd /correct/project
code-vector-cli stats  # Verify location
```

## Examples

```bash
# Find authentication code
code-vector-cli search "user authentication middleware" -n 10

# Find function by name
code-vector-cli search-hybrid "validateToken" --show-content

# Duplicate detection
code-vector-cli similar auth-service.js -t 0.85

# Context for new feature
code-vector-cli context "implement OAuth login" -n 15

# Impact of refactoring
code-vector-cli impact shared/utils.js -t 0.6

# Why feature exists
code-vector-cli search-git "OAuth implementation"

# Past discussions
code-vector-cli search-conversations "auth refactoring" -n 5
```

## Pro Tips

1. **Combine searches**: Use multiple commands to build complete picture
2. **Adjust thresholds**: Start low, increase until signal > noise
3. **Show content sparingly**: Only when you need to see code
4. **Hybrid for names**: Use hybrid search for specific identifiers
5. **Context first**: Run `context` before implementing new features
6. **Check history**: `search-git` and `search-conversations` reveal "why"

## Integration

```bash
# With grep
code-vector-cli search "error handling" | grep "try-catch"

# With git
FILES=$(code-vector-cli search "feature" --json | jq -r '.[].file_path')
git log --oneline -- $FILES

# In scripts
code-vector-cli search "query" --json | jq '.[] | .file_path'
```
