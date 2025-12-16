# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## ⚠️ CRITICAL: Read Code Style Guide First

**Before writing ANY code, you MUST read `docs/code-style.md` using the Read tool.**

This document defines ALL coding standards for this project:
- Type safety rules (NewType, no `Any`, Pydantic schemas)
- Flow organization (orchestrator task pattern, top-level resource instantiation)
- Configuration management (explicit `AppConfig`, Pydantic models)
- Error handling, naming conventions, and database operations

**Related documentation:**
- `docs/test-style.md` - Testing standards (no `unittest.mock`, class-based fakes, 90% coverage)
- `docs/troubleshooting.md` - Common issues, debug procedures, and solutions
- `docs/architecture.md` - Architectural overview, layouts, and public contracts
- `docs/infrastructure-style.md` - Terraform/IaC standards, CI/CD pipelines, deployment strategies, monitoring

**Do not skip this step.** The code-style.md file contains enforceable rules that will cause your code to be rejected if not followed.

## Module Discovery: Read doc.md First

**When exploring or modifying a module, ALWAYS read its `doc.md` file first before reading code.**

Each module in `src/` should have a `doc.md` file that explains:
- What the module does and its purpose
- How to use it and what services consume it
- Internal architecture and key components
- Gherkin-style use cases and examples

**Discovery order:**
1. Read `{module}/doc.md` to understand the module's purpose
2. Then read relevant code files as needed

Example: Before working on `src/api/`, first read `src/api/doc.md` (if it exists).

---

## Development Workflow

### Always Use Git Worktrees for Features

**CRITICAL: Work on features in separate git worktrees, not on main branch directly**

**Why worktrees:**
- Isolate feature work from main branch
- Easy context switching between features
- No stashing/committing required when switching tasks
- Clean separation of concerns

**Check if you're in a worktree:**
```bash
git worktree list
```

**If no worktree in path, advise user:**
"I notice you're not in a git worktree. For feature development, it's recommended to create a worktree. Would you like me to help set one up?"

**Command for user to copy-paste:**
```bash
# From your main project directory:
git worktree add ../project-feature-name -b feature-name
cd ../project-feature-name
```

Replace `feature-name` with descriptive name (e.g., `add-user-auth`, `refactor-storage`)

---

# When to use the MCP agents

**GPT-Architect** - Architecture and design consultation
- WHEN: After creating initial plan for big features/refactoring (step 0)
- WHEN: Before finalizing test architecture for substantial changes (step T-1)
- PURPOSE: Validate abstractions, challenge complexity, ensure correct layout

**GPT-Reviewer** - Code review and style compliance
- WHEN: Before running/updating tests (step T)
- WHEN: After running tests (step T+1)
- WHEN: Before final submission (step L-1)
- PURPOSE: Ensure code-style.md compliance, catch bugs

**GPT-Troubleshooter** - Debugging assistance
- WHEN: Bug takes more than 1 attempt to solve
- WHEN: After consulting docs/troubleshooting.md
- PURPOSE: Suggest logging, verify assumptions, plan debugging approach

Don't confirm those usages with user, it is always allowed.

You should wait for mcp to answer before asking followup otherwise you into session not found error.
These thinking models are heavy and can go on up to 10 minutes to answer, don't time them out.

Architect and Reviewer are your colleagues, don't wait until the last moment to talk to them. They are here to help and will provide you feed back thoughout planning and coding sessions, not just at the end. For example when you go though coding tasks in your plan review each one. And then a final review too. They are GPT 5.1 PROD with high thinking budget and could take up to 5 min to reply as they analyse the surrounding code.

Mind this error >
Failed to parse conversation_id: invalid character: expected an optional prefix of `urn:uuid:` followed by [0-9a-fA-F-], found `s` at 2

When you talk with them.

**⚠️ KNOWN ISSUE: MCP Agents Not Responding**

If GPT-5 agents return "Tool ran without output or errors":
- Could be codex pending updates or refresh token issues
- You can run `codex exec "prompt here"` via Bash tool to help debug
- Don't retry repeatedly - inform user and try to troubleshoot it yours

When you PLAN or make a ToDo list for a feature, refactoring or a fix, ALWAYS include following steps:
step 0 - talk to the architect.
...
step T-1(before running or updating tests) - talk with test gpt5-architect, if task involves substantial changes.
Step T+1(after running tests) - talk with test gpt5-reviewer
...
Step L-1(before last) - Consult with gpt5-reviewer again to check final version of your changes.
step L(last) - Documentation Update Step

**CRITICAL: Every implementation MUST update documentation**

This step is REQUIRED - do not skip. Check if any of these apply:

### Code Changes → docs/code-style.md
- Did you introduce a new development pattern or principle?
- Did user clarification reveal a non-obvious rule?
- Add examples showing the pattern

### Test Changes → docs/test-style.md
- Did you create a new testing pattern or approach?
- Did you add new fake class patterns?
- Document the approach with examples

### Bug Fixes → docs/troubleshooting.md
- Did you encounter a bug that took multiple attempts to solve?
- Did you discover a new error pattern?
- Add: symptoms, detection method, fix, and search command

### Architecture Changes → docs/architecture.md
- Did you add new services or modules?
- Did you change how components interact?
- Update: layouts, public contracts, service descriptions

### Infrastructure Changes → docs/infrastructure-style.md
- Did you add or modify Terraform/IaC code?
- Did you change CI/CD pipelines or deployment strategies?
- Did you update monitoring, alerting, or disaster recovery?
- Add: infrastructure patterns, security configurations, deployment procedures

### New Modules → {src,tests}/{module}/doc.md
- Create doc.md for each new module/service with:
  - What it does and its purpose
  - How to use it and what services consume it
  - Internal architecture
  - **Gherkin-style use cases** (see docs/code-style.md section 2.13)

### Decision Criteria:
- User gave clarification during planning/implementation → There was something non-obvious → Document it
- Found a special case vs. general rule → Confirm with user which it is → Update docs accordingly

# Troubleshooting

When you come across a bug that takes more than 1 attempt to solve consult with the docs/troubleshooting.md, and talk to the gpt5-troubleshooter. After planning a troubleshooting activity based on user input, update the troubleshooting guide with the new approach (if it was given).
