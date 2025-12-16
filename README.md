# Claude Code Steering Framework

> **Guidance that persists. Standards that enforce.**

## What is This?

This project is a **comprehensive steering framework** for Claude Code that preserves your development style, standards, and guidance in documentation. Instead of repeatedly instructing AI assistants about your preferences, this framework:

- **Captures your guidance** in structured documentation
- **Enforces your standards** automatically through MCP agents
- **Preserves your style** across all development sessions
- **Scales your expertise** via GPT-5.2-powered consultants

**Core Philosophy:** Guidance that persists. Standards that enforce.

## What is Steering?

**Steering** is the practice of capturing your development guidance in version-controlled documentation, then having AI agents automatically enforce it during every code change.

**Traditional approach:**
- Manually review every pull request
- Repeatedly explain the same standards in code reviews
- Hope developers remember your preferences
- Standards drift over time as context is lost

**Steering approach:**
- Document your standards once in `docs/`
- GPT-5.2 agents read and enforce them automatically
- Standards evolve with git history
- New patterns discovered → added to docs → enforced everywhere

**Key difference:** Your expertise becomes infrastructure, not tribal knowledge.

## Origins

This framework emerged from a **real Python project** (0 to ~200,000 lines of code) where development principles were captured and refined through iterative steering with Claude Code. The project specifics have been stripped away, but the **fundamental software development principles** remain:

- **Language-agnostic principles** - Testability, type safety, clear abstractions, systematic debugging
- **Python-specific practices** - Modern type hints, Pydantic schemas, ABC patterns, inheritance-based fakes
- **Battle-tested patterns** - Every rule in `docs/` solved a real problem or prevented a real bug

The documentation is structured to **separate universal principles from language-specific rules**, making it easy to adapt this framework to other languages (TypeScript, Go, Rust, etc.) while preserving the core development philosophy.

## Quickstart (5 Minutes)

This repository is a **template/steering pack** for Claude Code. Here's what you get:

1. **Pre-configured MCP agents** - Three GPT-5.2 specialist agents ready to enforce your standards
2. **Comprehensive documentation** - 5 detailed guides covering code style, testing, architecture, troubleshooting, and infrastructure
3. **Workflow automation** - Claude Code automatically consults agents at key development steps
4. **Self-improving** - Documentation updates with every new pattern discovered

**What's runnable today:**
- Read the documentation in `docs/` to understand the coding standards
- Review MCP agent configurations in `prompts/`
- Start a Claude session and ask it to plan a feature - it will automatically consult the agents
- Clone this as your project template and customize the standards to your preferences

**What you'll add:**
- `src/` - Your application code (following docs/code-style.md)
- `tests/` - Your test suite (following docs/test-style.md)

**Adapting to other languages:**
- Documentation is split into **Fundamental Principles** (language-agnostic) and **Python-Specific Rules**
- Keep the fundamental principles sections intact
- Ask Claude Code: *"Translate the Python-specific sections to TypeScript/Go/Rust"*
- Review Claude's translation and enhance as needed
- Update MCP agent prompts to reference your language standards

**Example workflow for TypeScript:**
```
User: "Read docs/code-style.md and translate all Python-specific sections to TypeScript. Keep the fundamental principles unchanged."

Claude: [Produces TypeScript-specific type system rules, testing patterns, etc.]

User: "Review and enhance the TypeScript translation with best practices."

Claude: [Refines the translation, adds TypeScript idioms]
```

## How It Works

### 1. Documentation as Steering Mechanism

All your development preferences are documented in:
- `docs/code-style.md` - Your coding standards (type safety, patterns, architecture)
- `docs/test-style.md` - Your testing philosophy (no mocks, inheritance-based fakes, 90% coverage)
- `docs/troubleshooting.md` - Your debugging approaches and common solutions
- `docs/architecture.md` - Your system architecture and design patterns
- `docs/infrastructure-style.md` - Your infrastructure standards (Terraform/IaC, CI/CD, deployment)
- `CLAUDE.md` - Your workflow and process guidance for Claude Code

### 2. Automated Enforcement via MCP Agents

Three GPT-5.2 specialist agents automatically enforce your standards:

| Agent | MCP Server Name | When | Purpose |
|-------|-----------------|------|---------|
| **GPT-Architect** | `gpt5-architect` | Step 0, Step T-1 | Validates design decisions against your architectural principles |
| **GPT-Reviewer** | `gpt5-reviewer` | Step T, T+1, L-1 | Ensures code compliance with your standards |
| **GPT-Troubleshooter** | `gpt5-troubleshooter` | When debugging | Applies your systematic troubleshooting methodology |

**Note:** Display names (GPT-Architect) and MCP server names (`gpt5-architect`) refer to the same agents.

These agents read your documentation and enforce it on every feature, refactoring, or bug fix.

### 3. Self-Improving Documentation

Every development session updates the documentation (Step L):
- New patterns discovered → Added to code-style.md
- Bugs encountered → Added to troubleshooting.md
- Architectural decisions → Captured in architecture.md

**Result:** Your guidance gets stronger over time, never repeats, always available.

## Prerequisites

### Required Tools

1. **Claude Code** - The AI-powered CLI for software engineering
   - Product page: https://claude.com/code
   - Requires Claude Pro or API access

2. **Codex CLI** - MCP server runtime for GPT-5.2 agents
   - GitHub: https://github.com/openai/codex
   - Version: 0.72.0+

3. **Node.js** - For Context7 MCP agent
   - Required to run npx commands
   - Version: 18+ recommended

4. **Python** - 3.12+
   - For project code (when you start writing actual application code)

5. **Git** - For version control and worktree workflow

6. **Context7 API Key** - For library documentation lookup
   - Sign up at: https://context7.ai
   - Free tier available

## Installation

### Step 1: Install Claude Code

```bash
# macOS (via Homebrew)
brew install --cask claude-code

# Or download from: https://claude.com/code
```

Verify installation:
```bash
claude --version
```

### Step 2: Install Codex CLI

```bash
# macOS (via Homebrew)
brew install --cask codex

# Or download from: https://github.com/openai/codex
```

Verify installation:
```bash
codex --version  # Should show v0.72.0+
```

Configure Codex with your OpenAI API key (for GPT-5.2 access):
```bash
# Set up authentication
codex login

# Or set environment variable
export OPENAI_API_KEY="your-api-key"
```

### Step 3: Clone This Repository

```bash
git clone https://github.com/your-username/claudecode-steering-blog.git
cd claudecode-steering-blog
```

**Note:** Replace `your-username` with your actual GitHub username if you've forked this repo.

### Step 4: Configure Context7 API Key

**Context7 provides library documentation lookup while coding**

**1. Get API Key:**
Visit https://context7.ai and sign up for a free API key

**2. Set environment variable:**
```bash
# Add to ~/.bashrc, ~/.zshrc, or equivalent
export CONTEXT7_API_KEY="your-api-key-here"

# Reload shell
source ~/.bashrc  # or ~/.zshrc
```

**3. Verify:**
```bash
echo $CONTEXT7_API_KEY  # Should display your key
```

Context7 is already configured in `.mcp.json` and will be available once the environment variable is set.

### Step 5: Verify MCP Agents

Test that all MCP agents are configured:

```bash
# From project root
claude mcp list
```

You should see:
- ✅ gpt5-architect - Connected
- ✅ gpt5-reviewer - Connected
- ✅ gpt5-troubleshooter - Connected

**Note:** `claude mcp list` only checks connectivity. To verify authentication and full functionality, start a Claude session and the agents will be tested when first invoked.

## Project Structure

```
claudecode-steering-blog/
├── docs/                      # Your steering documentation
│   ├── code-style.md         # Coding standards
│   ├── test-style.md         # Testing standards
│   ├── troubleshooting.md    # Debug procedures
│   ├── architecture.md       # System architecture
│   └── infrastructure-style.md # Infrastructure standards (Terraform, CI/CD)
├── prompts/                   # MCP agent system prompts
│   ├── architect.txt         # Architect agent configuration
│   ├── reviewer.txt          # Reviewer agent configuration
│   └── troubleshooter.txt    # Troubleshooter agent configuration
├── scripts/                   # MCP agent launchers
│   └── gpt5-agent.sh         # Unified script for all three GPT-5 agents
├── .mcp.json                  # MCP server configuration
├── CLAUDE.md                  # Claude Code workflow guidance
├── AGENTS.md                  # Agent usage notes
└── README.md                  # This file
```

**Note:** `src/` and `tests/` directories will be created when you start writing code.

## Usage

### Start a Development Session

```bash
# Use git worktrees for feature isolation (recommended)
git worktree add ../myproject-feature -b feature-name
cd ../myproject-feature

# Start Claude Code
claude
```

Claude will:
1. Read `CLAUDE.md` for workflow guidance
2. Consult GPT-Architect when planning features
3. Consult GPT-Reviewer before/after tests
4. Enforce your standards automatically
5. Update documentation with new patterns (Step L)

### Git Worktree Workflow

**ALWAYS use git worktrees for feature development** - this is enforced in CLAUDE.md

**Why worktrees:**
- Isolate each feature in its own directory
- Switch between features instantly (no stashing)
- Work on multiple features in parallel
- Keep main branch clean

**Setup a new feature:**
```bash
# From your main project directory
cd /path/to/claudecode-steering-blog

# Create worktree for new feature
git worktree add ../claudecode-steering-blog-feature-name -b feature-name

# Move into the worktree
cd ../claudecode-steering-blog-feature-name

# Start Claude Code
claude
```

**List your worktrees:**
```bash
git worktree list
```

**Remove a worktree when done:**
```bash
git worktree remove ../claudecode-steering-blog-feature-name
```

### Planning Mode: Always Plan Before Editing

**CRITICAL: Use planning mode for all non-trivial changes**

When Claude suggests changes, ALWAYS use planning mode first:

1. **Trigger planning mode** - Claude will enter plan mode for complex tasks
2. **Review the plan** - Inspect proposed changes before any code is written
3. **Provide feedback** - Ask questions, request changes to approach
4. **Approve or reject** - Only accept plan when satisfied
5. **Execution** - Claude implements after plan approval

**Benefits:**
- See the approach before code is written
- Catch design issues early
- No wasted effort on wrong direction
- Clear understanding of changes

**In Claude Code:**
- Planning mode is triggered automatically for complex tasks
- You can always request to see a plan first
- Plans include file changes, new files, testing approach
- MCP agents (Architect, Reviewer) are consulted during planning

### Context7: Library Documentation Lookup

**Context7 provides instant access to library documentation while coding**

*Note: Context7 API key should already be configured from Step 4 of Installation. If not, see that section.*

#### Using Context7

**During development, Claude can:**
- Look up library documentation automatically
- Get latest API references
- Find usage examples
- Check compatibility

**Example:**
```
User: "Use httpx for API calls"

Claude (via Context7):
  ├─ Looks up httpx documentation
  ├─ Finds async client examples
  ├─ Checks latest version compatibility
  └─ Implements with best practices
```

**Manual lookup:**
```
User: "What's the context7 documentation for Pydantic?"
Claude: [Uses context7 MCP agent to fetch Pydantic docs]
```

**Supported libraries:** Most popular Python, JavaScript, and other languages

### Typical Development Flow

```
User: "Add user authentication feature"

Claude:
  ├─ Reads docs/code-style.md, docs/architecture.md
  ├─ Creates implementation plan
  ├─ Step 0: Consults GPT-Architect (validates design)
  ├─ Implements feature following your standards
  │   ├─ NewType for UserIds
  │   ├─ Pydantic schemas for data
  │   ├─ ABC (not Protocol) for interfaces
  │   ├─ Dependencies passed as parameters (testable)
  │   └─ Context managers for resources
  ├─ Step T: Consults GPT-Reviewer (pre-test review)
  ├─ Writes tests (inheritance-based fakes, no mocks)
  ├─ Step T+1: Consults GPT-Reviewer (post-test review)
  ├─ Step L-1: Final review with GPT-Reviewer
  └─ Step L: Updates documentation with new patterns
```

### MCP Agents in Action

**GPT-Architect** (Step 0, T-1):
```
Reviewing your plan for user authentication...

✅ Approvals:
- Business logic testable (dependencies passed as parameters)
- NewType(UserId) defined in src/utils/types.py
- Pydantic schemas for User, Credentials
- Using ABC, not Protocol ✓

⚠️ Concerns:
- src/auth/service.py:45 - Thin wrapper detected
  Recommendation: Expose auth.sessions.create() directly

💡 Recommendations:
- Consider ABC for shared session logic
- Check if auth library already exists (httpx-auth, authlib)?
```

**GPT-Reviewer** (Step T, T+1, L-1):
```
Reviewing code changes...

✅ Approvals:
- Type safety: All IDs use NewType ✓
- Modern syntax: Using list[str] not List[str] ✓

🐛 Bugs Found:
- src/auth/service.py:67 - Unhandled None return
  Fix: Add None check before accessing result.user_id

⚠️ Standards Violations:
- tests/unit/auth/test_service.py:12 - Using unittest.mock
  Fix: Replace with inheritance-based FakeAuthService
```

**GPT-Troubleshooter** (When debugging):
```
🔍 Hypothesis:
Database connection not properly closed in error path

✅ Verification Plan:
1. Add logging at auth/service.py:45 (before DB call)
2. Add logging at auth/service.py:52 (after DB call)
3. Run: grep -r "Database(" src/ (find similar patterns)

⚡ Speed Up Debugging:
pytest -k "test_auth_failure" -v
```

## Documentation Standards

### Your Guidance is Captured In:

**docs/code-style.md** - Enforces:
- Zero `Any` types in business logic
- NewType for all domain IDs
- Pydantic schemas for all data contracts
- Orchestrator pattern for testability
- ABC for >50% code reuse
- No Protocol in internal code
- No thin wrappers

**docs/test-style.md** - Enforces:
- No `unittest.mock` or `monkeypatch`
- Inheritance-based fakes only
- 90% coverage target on business logic
- Bug fixes must include test cases

**docs/troubleshooting.md** - Guides:
- 8 systematic troubleshooting principles
- Search for similar bugs before fixing
- Minimize time to reproduce
- Common error patterns with solutions

## Customizing for Your Project

### Update Your Standards

Edit the documentation files to match your preferences:

```bash
# Edit coding standards
vim docs/code-style.md

# Edit testing standards
vim docs/test-style.md

# Edit troubleshooting approaches
vim docs/troubleshooting.md
```

The MCP agents will automatically enforce your updated standards.

### Customize MCP Agents

Edit the agent system prompts:

```bash
# Customize architect behavior
vim prompts/architect.txt

# Customize reviewer behavior
vim prompts/reviewer.txt

# Customize troubleshooter behavior
vim prompts/troubleshooter.txt
```

Changes take effect immediately (agents reload prompts on each invocation).

## Security Considerations

**⚠️ Important Security Notes:**

1. **`.mcp.json` executes local scripts** - The configuration file runs bash script (`scripts/gpt5-agent.sh`) when MCP agents are invoked. Always review this script before running.

2. **Supply chain risks** - If using `npx -y` for Context7 or other MCP agents, packages are downloaded and executed automatically. Consider:
   - Pinning specific versions in `.mcp.json`
   - Reviewing package contents before first use
   - Using local installations instead of `npx -y`

3. **API keys** - Store OpenAI and Context7 API keys in environment variables, never commit them to git.

4. **First-time approval** - Claude Code may prompt for approval when first accessing MCP servers. This is expected behavior - review what's being executed before approving.

**Recommendations:**
- Review all scripts in `scripts/` directory
- Inspect `.mcp.json` configuration before use
- Keep Codex and Claude Code updated
- Use git to track changes to agent configurations

## Key Features

### ✅ Steering Above All
- **Never repeat guidance** - Document once, enforced forever
- **Version-controlled standards** - Your guidance evolves with git
- **Automatic enforcement** - GPT-5.2 agents apply your rules

### ✅ Type Safety First
- NewType for all domain IDs
- Pydantic schemas for all data
- Zero `Any` types in business logic
- Modern Python 3.10+ syntax

### ✅ Testability by Design
- Orchestrator pattern (testable without dependencies)
- Inheritance-based fakes (no mocks)
- 90% coverage target
- Bug fixes require tests

### ✅ Systematic Debugging
- 8 troubleshooting principles
- Search for similar patterns
- Minimize iteration time
- GPT-5.2 debugging assistance

### ✅ Git Worktree Workflow
- Feature isolation
- Easy context switching
- No stashing required

## MCP Agent Details

### Architecture

```
Claude Code (You)
    ↓
CLAUDE.md (Workflow guidance)
    ↓
┌──────────────┬──────────────┬──────────────────┬─────────────┐
│              │              │                  │             │
│GPT-Architect │ GPT-Reviewer │GPT-Troubleshooter│  Context7   │
│(Step 0, T-1) │(T, T+1, L-1) │  (When debugging)│(Doc lookup) │
│              │              │                  │             │
└──────┬───────┴──────┬───────┴────────┬─────────┴──────┬──────┘
       │              │                │                │
       ↓              ↓                ↓                ↓
  code-style.md  test-style.md  troubleshooting.md  Library Docs
```

### Agent Capabilities

| Capability | GPT-Architect | GPT-Reviewer | GPT-Troubleshooter | Context7 |
|------------|---------------|--------------|-------------------|----------|
| MCP Server Name | `gpt5-architect` | `gpt5-reviewer` | `gpt5-troubleshooter` | `context7` |
| Read docs | ✅ | ✅ | ✅ | - |
| Read code | ✅ | ✅ | ✅ | - |
| Search codebase | ✅ | ✅ | ✅ | - |
| Library documentation | - | - | - | ✅ |
| API reference lookup | - | - | - | ✅ |
| Usage examples | - | - | - | ✅ |
| High reasoning budget | ✅ | ✅ | ✅ | - |
| Response time | 5-10 min | 5-10 min | 5-10 min | <1 sec |
| Model | GPT-5.2 | GPT-5.2 | GPT-5.2 | Context7 API |
| Reasoning effort | High | High | High | N/A |

## Contributing

This is a personal steering framework. Fork it and customize for your needs!

To share improvements back:
1. Fork the repository
2. Create a feature branch
3. Update documentation with your pattern
4. Submit a pull request

## License

Apache 2.0 - See LICENSE file

## Acknowledgments

- **Claude Code** by Anthropic - AI-powered development CLI
- **Codex** by OpenAI - MCP server runtime powering the GPT-5.2 agents
- **GPT-5.2** by OpenAI - Powers the three specialist MCP agents (Architect, Reviewer, Troubleshooter)
- **Context7** - Library documentation lookup and API reference

---

**Remember:** Guidance that persists. Standards that enforce.
