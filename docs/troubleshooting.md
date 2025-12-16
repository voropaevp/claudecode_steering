# Troubleshooting Guide

This document provides general troubleshooting principles and debugging procedures.

**Related documentation:**
- [Code Style Guide](code-style.md) - Coding standards
- [Test Style Guide](test-style.md) - Testing standards

---

## General Troubleshooting Principles

### 1. Search for Similar Errors First

**CRITICAL: Before fixing any bug, always search the codebase for similar errors or patterns.**

When you encounter an error:

1. **Search for similar error patterns** - Use grep/search to find similar issues:
   ```bash
   # Search for similar error messages
   grep -r "error message pattern" src/

   # Search for similar code patterns that might have the same bug
   grep -r "problematic_pattern" src/
   ```

2. **Check if the fix applies elsewhere** - If you find a bug:
   - Search for the same pattern across the codebase
   - Fix ALL instances of the bug, not just the one you encountered
   - This prevents the same bug from appearing in multiple places

3. **Document the pattern** - After fixing:
   - Add the error pattern to this troubleshooting guide
   - Include how to detect it and how to fix it
   - Create a test case to prevent regression

**Example:**
```
Bug found: Database connection not properly closed in user_service.py
Action: Search for similar patterns in all services
Found: 3 other services with the same issue
Fix: Apply context manager pattern to all 4 services
Document: Add "Always use context managers for DB connections" to this guide
```

### 2. Reproduce Before Fixing

**Never fix a bug you can't reproduce.**

Steps:
1. Write a test that reproduces the bug (it should fail)
2. Fix the bug
3. Verify the test passes
4. Look for similar bugs (see principle #1)

### 3. Add Logging for Complex Bugs

When a bug is hard to understand:

1. **Add strategic logging**:
   ```python
   logger.debug(f"Processing item {item_id}, state: {state}")
   logger.debug(f"Before operation: {variable_state}")
   # ... operation
   logger.debug(f"After operation: {variable_state}")
   ```

2. **Log at boundaries**:
   - Function entry/exit
   - State transitions
   - External service calls
   - Error conditions

3. **Remove or reduce logging** after fixing:
   - Keep critical error logs
   - Remove verbose debug logs
   - Or reduce debug logs to INFO level

### 4. Check Assumptions

When debugging:

1. **List your assumptions** about how the code works
2. **Verify each assumption** with logging or debugger
3. **Don't assume the obvious** - check it
4. **Question third-party library behavior** - they have bugs too

### 5. Isolate the Problem

**Narrow down the issue:**

1. **Binary search** - Comment out half the code, see if bug persists
2. **Minimal reproduction** - Create smallest possible test case
3. **Check dependencies** - Is it your code or a library?
4. **Check environment** - Does it work in different environment?

### 6. Use Type Checking

**Many bugs are caught by mypy:**

```bash
# Run type checking
uv run mypy .

# Fix type errors - they often reveal real bugs
```

If mypy reports an error, it's often a real bug, not a false positive.

### 7. Talk to GPT-5 Troubleshooter

When stuck after multiple attempts:

1. **Consult this troubleshooting.md** first
2. **Talk to gpt5-troubleshooter** (MCP agent)
   - Explain what you've tried
   - Share relevant code and errors
   - Get suggestions for logging and debugging approach

3. **Update this guide** with the solution

### 8. Minimize Time to Reproduce

**When a bug persists across multiple iterations, optimize your debugging feedback loop**

If an error in tests persists after 2-3 debugging attempts:

**1. Isolate the failing test**
```bash
# Run only the failing test
uv run pytest tests/unit/services/test_user.py::test_specific_function -v

# Disable other tests temporarily
# Comment out other test files or use pytest -k flag
uv run pytest -k "test_specific_function" -v
```

**2. Speed up test execution**
- **Persistent test runner** - Keep pytest session alive:
  ```bash
  uv run pytest-watch tests/unit/  # Auto-runs on file changes
  ```

- **Docker layer caching** - Ensure Docker is caching dependencies:
  ```bash
  # Use BuildKit for better caching
  DOCKER_BUILDKIT=1 docker build --cache-from myapp:latest .
  ```

- **Cloud instance with pre-installed libraries**:
  - Spin up cloud VM with environment pre-configured
  - Avoid reinstalling dependencies on each run

- **Disable unrelated CI/CD actions**:
  - Temporarily disable linting, type checking in CI
  - Focus only on the failing test
  - Re-enable after fix

**3. Use faster feedback mechanisms**
```python
# Add print debugging for immediate feedback
print(f"DEBUG: variable_state = {variable_state}")

# Use pdb for interactive debugging
import pdb; pdb.set_trace()

# Run with pdb on failure
uv run pytest tests/ --pdb
```

**Goal:** Reduce iteration time from minutes to seconds when debugging persistent issues

---

## Common Error Patterns

### Pattern: Resource Not Closed

**Problem:** Database connections, file handles, or other resources not properly closed.

**Symptoms:**
- "Too many open connections" errors
- Memory leaks
- File locks

**Detection:**
```bash
# Search for resources without context managers
grep -n "\.open(" src/
grep -n "Client(" src/ | grep -v "with "
```

**Fix:** Use context managers
```python
# ❌ Bad
db = Database(uri)
result = db.query()
db.close()  # Might not execute if exception occurs

# ✅ Good
with Database(uri) as db:
    result = db.query()
# Automatic cleanup
```

**Search for similar:** After fixing, search entire codebase for same pattern

---

### Pattern: Unhandled None

**Problem:** Function can return None, but calling code doesn't handle it.

**Symptoms:**
- `AttributeError: 'NoneType' object has no attribute 'X'`
- Crashes in production

**Detection:**
```bash
# Find functions that might return None
mypy src/ | grep "None"
```

**Fix:** Check for None before using
```python
# ❌ Bad
result = get_data(id)
value = result.field  # Crashes if result is None

# ✅ Good
result = get_data(id)
if result is None:
    logger.warning(f"No data for {id}")
    return default_value
value = result.field
```

**Search for similar:** Check all calls to functions that return `T | None`

---

### Pattern: Type Mismatch

**Problem:** Passing wrong type to function.

**Symptoms:**
- Runtime type errors
- Unexpected behavior

**Detection:**
```bash
# Run mypy
uv run mypy src/
```

**Fix:** Use correct types and NewType
```python
# ❌ Bad - string looks like ID but isn't typed
def get_user(user_id: str) -> User:
    ...

get_user("123")  # Is this really a user ID or just a string?

# ✅ Good - NewType prevents mixing
UserId = NewType("UserId", str)

def get_user(user_id: UserId) -> User:
    ...

get_user(UserId("123"))  # Clear intent
```

**Search for similar:** Look for all string IDs that should be NewType

---

### Pattern: MCP Conversation ID Parsing Error

**Problem:** MCP agent returns "Failed to parse conversation_id" error

**Symptoms:**
- Error message: "expected an optional prefix of `urn:uuid:` followed by [0-9a-fA-F-], found `s` at 2"
- Occurs when trying to use mcp__*__codex-reply

**Detection:**
Check if you're passing a malformed conversationId to codex-reply

**Fix:**
1. Ensure you're using the correct conversationId from the initial codex call
2. Don't manually construct conversation IDs
3. Wait for the first call to complete before using reply

**Prevention:**
Always wait for MCP agents to respond (can take 5-10 minutes) before sending follow-ups

---

## Debugging Workflow

1. **Reproduce** - Create failing test
2. **Search** - Look for similar bugs in codebase
3. **Isolate** - Narrow down to smallest reproduction
4. **Hypothesize** - Form theory about the cause
5. **Verify** - Add logging to check hypothesis
6. **Fix** - Make the change
7. **Search again** - Find and fix similar patterns
8. **Test** - Verify fix works
9. **Document** - Update this guide if pattern is common

---

## When to Ask for Help

Ask for help when:
1. Bug persists after 3+ debugging attempts
2. You've followed all principles above
3. You've consulted this guide and gpt5-troubleshooter
4. The bug is blocking critical work

Before asking:
1. Document what you've tried
2. Provide minimal reproduction
3. Share relevant logs and code
4. Explain your assumptions

---

## Updating This Guide

When you solve a difficult bug:

1. Add the error pattern to "Common Error Patterns"
2. Include symptoms, detection method, and fix
3. Add example code
4. Commit the update with the bug fix

This guide should grow with real-world issues from this project.
