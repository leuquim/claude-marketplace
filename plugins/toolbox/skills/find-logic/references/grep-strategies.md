# Grep Strategies

Use when vector search unavailable or for EXACT queries.

## Step-by-Step Process

### Step 1: Extract Keywords

From user query, extract 1-2 keywords:
- "Where do we check for duplicate bookings?" → `duplicate`, `booking`
- "What controls the rate limit?" → `rateLimit`, `rate_limit`

### Step 2: First Grep - Find Files

```
Grep pattern: "keyword1.*keyword2|keyword2.*keyword1"
output_mode: "files_with_matches"
```

Tips:
- Include both naming conventions: `total_time|totalTime`
- Combine related terms: `duplicate|checkDuplicate|isDuplicate`

### Step 3: Second Grep - Get Context

Pick most relevant file from Step 2:
```
Grep pattern: "{keyword}"
path: "{file_from_step_2}"
-C: 5
output_mode: "content"
```

### Step 4: Check Completion

Can you fill ALL of these?
1. File path: ___
2. Line number: ___
3. Actual code: ___
4. What it does: ___

- YES → Report answer
- NO, code calls another function → Grep for that function name
- NO, no results after 2 patterns → Try Glob

## Glob Fallback

Only if Grep returns nothing after 2 tries:
```
Glob pattern: "**/*{Keyword}*.{php,js,ts}"
```

## Tool Priority

1. Grep `files_with_matches` → find files
2. Grep with `-C 5` → get context
3. Read → only for small files (config, constants, utils)
4. Glob → last resort

## Files Safe to Read

- `*Util.js`, `*util.js`
- `constants.*`, `config.*`, `types.*`
- Files in `utils/` directory
- `*Trait.php`, `*Helper.php`

## Files Never Read Directly

Use Grep with context instead:
- `*Component.js`, `*Screen.js`
- `*Controller.php`
- Files > 500 lines
