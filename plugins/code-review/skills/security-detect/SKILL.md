---
name: security-detect
description: Detect security vulnerabilities in code. Use for: injection risks, hardcoded secrets, auth/authz gaps, data exposure, OWASP Top 10 coverage. Language-agnostic patterns with language-specific checks.
---

# Security Detection Skill

Identify security vulnerabilities and risks in code.

## Detection Categories

### 1. Injection Vulnerabilities

**SQL Injection:**
- String concatenation in queries: `query = "SELECT * FROM " + table`
- Template literals with user input: `` `SELECT * FROM ${userInput}` ``
- Missing parameterization in ORM raw queries

**Command Injection:**
- User input in exec/spawn/system calls
- Template strings in shell commands
- Unsanitized arguments to child_process

**XSS:**
- `innerHTML`, `dangerouslySetInnerHTML` with user data
- Unescaped output in templates
- `document.write()` with dynamic content

**Path Traversal:**
- User input in file paths without validation
- Missing `path.normalize()` or equivalent
- `../` not filtered from path inputs

### 2. Hardcoded Secrets

**Patterns to detect:**

```
password\s*[:=]\s*["'][^"']+["']
api[_-]?key\s*[:=]\s*["'][^"']+["']
secret\s*[:=]\s*["'][^"']+["']
token\s*[:=]\s*["'][A-Za-z0-9+/=]{20,}["']
private[_-]?key
-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----
```

**Exclude:**
- Empty strings, "test", "example", "placeholder"
- Environment variable references
- Files in .gitignore

### 3. Authentication Issues

- Missing auth middleware on sensitive routes
- Passwords stored without hashing
- Weak hash algorithms (MD5, SHA1 for passwords)
- Missing rate limiting on auth endpoints
- Session tokens in URLs or logs

### 4. Authorization Issues

- Missing ownership checks before data access
- Direct object references without validation
- Role checks that can be bypassed
- Horizontal privilege escalation paths

### 5. Data Exposure

- Sensitive fields in API responses (password, SSN, etc.)
- PII in log statements
- Verbose error messages with stack traces to clients
- Sensitive data in URL parameters

## Detection Process

1. **Grep for patterns** - Quick scan for obvious issues
2. **Trace data flow** - Follow user input to sensitive sinks
3. **Check boundaries** - Verify auth/authz at entry points
4. **Assess context** - Is this internal/external, test/production?

## Output Format

For each finding:

```markdown
### [Severity] {Vulnerability Type}

**Location:** `file:line`
**Category:** {Injection|Secrets|Auth|Authz|DataExposure}

**Code:**
```{lang}
{vulnerable code snippet, 3-5 lines context}
```

**Risk:** {What could happen if exploited}

**Initial Severity:** {Critical|High|Medium|Low}
```

## Severity Guidelines

| Severity | Criteria |
|----------|----------|
| Critical | RCE, SQL injection with data access, production credentials |
| High | XSS with session access, auth bypass, command injection |
| Medium | CSRF, info disclosure, missing rate limiting |
| Low | Missing headers, verbose errors (non-sensitive) |

## Language-Specific Checks

**JavaScript/TypeScript:**
- `eval()`, `Function()` with user input
- `child_process` without array args
- Missing CORS configuration

**Python:**
- `pickle.loads()` on untrusted data
- `subprocess` with shell=True
- SQL string formatting

**Go:**
- `fmt.Sprintf` in SQL queries
- Missing input validation on handlers
- Unchecked type assertions

**Java:**
- `Runtime.exec()` with concatenation
- `XMLInputFactory` without disabling external entities
- Deserialization of untrusted data
