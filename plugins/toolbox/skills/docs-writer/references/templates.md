# Document Templates

Use these templates exactly. Omit sections that don't apply; never add sections.

## README

```markdown
# project-name

One sentence explaining what this does and who it's for.

## Install

[package manager command]

## Quick Start

[single working example - 5-10 lines max]

## Documentation

- [Feature A](./docs/feature-a.md)
- [API Reference](./docs/api.md)

## License

[license type]
```

**Sections explained:**
- Title: Package name, no tagline
- Description: What + who, one sentence
- Install: One command, no alternatives
- Quick Start: Minimal working example
- Documentation: Links only, no descriptions
- License: Type only, link to LICENSE file if needed

---

## Feature Doc

```markdown
# Feature Name

What this does and when to use it.

## Usage

[primary use case with working example]

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| name   | type | value   | One line    |

## See Also

- [Related Feature](./related.md)
```

**Sections explained:**
- Title: Feature name only
- Description: What + when, one paragraph max
- Usage: One example showing typical case
- Options: Table format, one line per option
- See Also: Links to related docs

---

## API Reference

Per-endpoint format:

```markdown
## `GET /endpoint`

Brief description of what this returns.

**Parameters:**

| Name | Type | Required | Description |
|------|------|----------|-------------|
| id   | string | yes    | Resource ID |

**Response:**

{
  "field": "value"
}

**Example:**

curl -X GET https://api.example.com/endpoint?id=123
```

**Rules:**
- One heading per endpoint
- Description: one sentence
- Parameters: table format
- Response: actual JSON shape
- Example: working curl command

---

## Guide

```markdown
# How to [Accomplish Goal]

Brief context if needed (1-2 sentences max).

## Prerequisites

- Requirement 1
- Requirement 2

## Steps

### 1. First Action

[instruction + code example]

### 2. Second Action

[instruction + code example]

## Verify

[how to confirm success]

## Next Steps

- [Related Guide](./next.md)
```

**Rules:**
- Title: "How to [verb]" format
- Prerequisites: max 5 items, else extract
- Steps: 5-8 max, else split into multiple guides
- Each step: one action + one example
- Verify: how user confirms success

---

## Changelog

```markdown
# Changelog

## [1.2.0] - 2024-01-15

### Added
- Feature description in one line

### Changed
- Change description in one line

### Fixed
- Fix description in one line

### Removed
- Removal description in one line
```

**Rules:**
- Newest version first
- Use Keep a Changelog categories only
- One line per item
- Link to issues/PRs if available
