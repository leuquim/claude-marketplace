# Code Vector Search Skill

A Claude Code skill for semantic code search using `code-vector-cli` - a vector database-powered tool for finding code by meaning, understanding architecture, and tracing changes.

## Overview

This skill enables Claude to efficiently search and understand your codebase using semantic vector embeddings, going beyond simple text matching to find code based on **what it does** rather than just what it's called.

## What This Skill Does

- **Semantic Code Search**: Find code by describing what you're looking for
- **Hybrid Search**: Combine semantic understanding with keyword precision
- **Similarity Detection**: Discover duplicate code and related patterns
- **Context Gathering**: Get relevant files for any task
- **Impact Analysis**: Understand change blast radius
- **Git History Search**: Find commits by topic, not just keywords
- **Conversation Search**: Search past Claude discussions for decisions and rationale

## Installation

The `code-vector-cli` tool should already be installed at:
- Binary: `~/.local/bin/code-vector-cli`
- Library: `~/.local/lib/code_vector_db/`

If not installed, check the project documentation.

## Quick Start

### 1. Initialize a Project

```bash
cd /path/to/your/project
code-vector-cli init  # Indexes code, docs, and configs
```

### 2. Optional: Index History

```bash
code-vector-cli index-git              # Last 1000 commits
code-vector-cli migrate-conversations  # Claude transcripts
```

### 3. Search

```bash
# Semantic search
code-vector-cli search "authentication middleware"

# Hybrid search (semantic + keyword)
code-vector-cli search-hybrid "validateToken function"

# Find similar code
code-vector-cli similar path/to/file.js
```

### 4. Daily Updates

```bash
# Fast incremental reindex (only changed files)
code-vector-cli index --incremental
```

## Command Quick Reference

| Command | Purpose | Example |
|---------|---------|---------|
| `search` | Find code by concept | `search "file upload handler"` |
| `search-hybrid` | Semantic + keyword | `search-hybrid "S3Service bucket"` |
| `similar` | Find related code | `similar path/to/file.js` |
| `context` | Gather task context | `context "add OAuth login"` |
| `impact` | Change blast radius | `impact auth-service.js` |
| `search-git` | Search commits | `search-git "S3 migration"` |
| `search-conversations` | Past discussions | `search-conversations "refactoring"` |
| `index --incremental` | Fast reindex | Daily use |
| `stats` | View index status | Check if indexed |

## Skill Files

- `SKILL.md` - Main skill documentation for Claude
- `README.md` - This file, human-readable overview
- `quick-reference.md` - Command cheat sheet

## How Claude Uses This Skill

When you ask Claude to:
- "Find code that handles X"
- "Show me examples of Y"
- "What files are relevant for implementing Z?"
- "Why was this feature implemented this way?"

Claude will automatically:
1. Identify the best search strategy
2. Choose appropriate commands and parameters
3. Execute searches via `code-vector-cli`
4. Interpret and present results
5. Suggest next steps

## Examples

### Example 1: Finding Code
**You:** "Find code that handles websocket connections"

**Claude uses:**
```bash
code-vector-cli search "websocket connection handling" -n 10
```

### Example 2: Understanding Impact
**You:** "I want to refactor the authentication middleware. What will be affected?"

**Claude uses:**
```bash
code-vector-cli impact middleware/authenticate.js
code-vector-cli search "authentication middleware usage" -n 20
```

### Example 3: Gathering Context
**You:** "I need to implement role-based permissions. What's relevant?"

**Claude uses:**
```bash
code-vector-cli context "role-based permissions system" -n 15
code-vector-cli search "authorization" --show-content
code-vector-cli search-conversations "permissions"
```

## Performance

- **Semantic search**: < 1 second
- **Hybrid search**: < 1 second
- **Full index**: Minutes (first time only)
- **Incremental index**: Seconds (500x faster for daily use)

## Troubleshooting

### Skill Not Loading
```bash
# Check skill exists
ls ~/.claude/skills/code-vector-search/SKILL.md

# Restart Claude Code if needed
```

### No Search Results
```bash
# Verify project is indexed
code-vector-cli stats

# If not indexed
code-vector-cli init
```

### Stale Results
```bash
# Quick update
code-vector-cli index --incremental

# Full refresh
code-vector-cli delete --force && code-vector-cli init
```

## Advanced Features

### Multi-Repo Workspaces
```bash
# Index entire workspace
cd /workspace/root
code-vector-cli init

# Search shows repo labels
code-vector-cli search "utility function"
# [repo1] lib/util.js
# [repo2] src/utils.js
```

### Tuning Search Quality

**Thresholds** (`-t`):
- `0.1-0.2`: Exploratory, many results
- `0.3` (default): Balanced
- `0.4-0.6`: Strict, high quality only

**Hybrid Weights**:
- Default: 70% semantic, 30% keyword
- Exact terms: `--semantic-weight 0.5 --bm25-weight 0.5`
- Concept-focused: `--semantic-weight 0.9 --bm25-weight 0.1`

## Integration with Other Tools

### With grep
```bash
# Concept search → exact matches
code-vector-cli search "error handling" -n 10
grep -r "try.*catch" $(code-vector-cli search "error handling" --json | jq -r '.[].file_path')
```

### With git
```bash
# Find related code and its history
FILES=$(code-vector-cli search "feature X" --json | jq -r '.[].file_path')
git log --oneline -- $FILES
```

## Technical Details

- **Vector DB**: Qdrant (localhost:6333)
- **Embeddings**: OpenAI text-embedding-3-small (1536 dimensions)
- **Storage**: `~/.local/share/code-vector-db/`
- **Metadata**: `~/.local/share/code-vector-db/indexes/project-registry.json`

## Limitations

1. **Requires indexing**: Projects must be indexed first
2. **Similarity, not dependencies**: `impact` shows similar code, not actual imports
3. **Semantic only**: Won't find code with completely different terminology
4. **English-centric**: Works best with English code/comments

## Best Practices

1. ✅ Use `--incremental` for daily indexing
2. ✅ Start with broad searches, narrow down with higher thresholds
3. ✅ Use `search-hybrid` for exact function/class names
4. ✅ Combine vector search with grep for comprehensive results
5. ❌ Don't use for exact string matching (use `grep`)
6. ❌ Don't skip incremental indexing (keeps results fresh)

## Contributing

Found a useful pattern or workflow? Add it to `SKILL.md` under "Workflow Patterns".

## License

Part of the code-vector-cli project.
