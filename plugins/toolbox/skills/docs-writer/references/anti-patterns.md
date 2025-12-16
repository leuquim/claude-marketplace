# Anti-Patterns

Detect and rewrite these patterns automatically.

## Voice Issues

| Pattern | Example | Rewrite |
|---------|---------|---------|
| Passive voice | "The file is read by the parser" | "The parser reads the file" |
| Hedging | "You might want to consider..." | Remove or make direct |
| Permission | "You can use this to..." | "Use this to..." |
| Possibility | "This could potentially..." | "This [does X]" |
| Suggestion | "It's recommended that..." | Direct imperative |

**Detection words:** might, could, may, possibly, potentially, recommended, consider, want to, able to, can be

---

## Verbosity

| Pattern | Example | Rewrite |
|---------|---------|---------|
| Filler phrases | "In order to" | "To" |
| Redundancy | "completely remove" | "remove" |
| Over-qualification | "very important" | "important" (or remove) |
| Meta-commentary | "This section explains..." | Start with the content |
| Obvious statements | "As you can see..." | Remove entirely |

**Filler phrases to remove:**
- "In order to" → "To"
- "Due to the fact that" → "Because"
- "At this point in time" → "Now"
- "In the event that" → "If"
- "It should be noted that" → Remove
- "It is important to note" → Remove
- "As mentioned above" → Remove

---

## Structure Issues

| Pattern | Problem | Fix |
|---------|---------|-----|
| Wall of text | Paragraph >5 lines | Break into bullets |
| Deep nesting | >1 level of list nesting | Flatten or use table |
| Empty sections | Section with no content | Remove section |
| Heading overload | >3 heading levels | Restructure |
| Orphan headings | Heading with <2 lines under | Merge with parent |

---

## Scope Creep

| Pattern | Detection | Action |
|---------|-----------|--------|
| Also additions | "Also...", "Additionally...", "Furthermore..." | Stop, suggest extraction |
| Tangents | "Note that...", "Keep in mind..." | Move to separate section or remove |
| Tutorial in README | Step count >3 | Extract to guide |
| Multiple audiences | "For developers... For users..." | Split into separate docs |
| Feature dump | >5 features listed | Summarize + link to feature docs |

---

## Common Rewrites

### Before/After Examples

**Hedging:**
```
Before: You might want to consider using the cache option if performance is a concern.
After: Enable caching for better performance.
```

**Passive:**
```
Before: The configuration file is loaded by the application on startup.
After: The application loads the configuration file on startup.
```

**Meta-commentary:**
```
Before: This section explains how to configure authentication.
After: ## Authentication
        Set the API key in your environment:
```

**Verbosity:**
```
Before: In order to install the package, you will need to run the following command.
After: Install the package:
```

**Wall of text:**
```
Before: The system supports multiple authentication methods including API keys,
        OAuth tokens, and session cookies. API keys are the simplest option
        and work well for server-to-server communication. OAuth is better
        for user-facing applications. Session cookies are used by the web UI.

After: Authentication methods:
       - API keys - server-to-server communication
       - OAuth - user-facing applications
       - Session cookies - web UI
```
