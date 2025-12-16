# Code Style Guide

This document defines the coding standards, architectural patterns, and organizational principles for this project.

**Related documentation:**
- [Test Style Guide](test-style.md) - Testing standards, patterns, and examples
- [Troubleshooting Guide](troubleshooting.md) - Common issues and debug procedures
- [Architecture](architecture.md) - System architecture and design patterns

---

## How to Use This Guide

This guide is structured in two parts:

**PART 1: FUNDAMENTAL SOFTWARE DEVELOPMENT PRINCIPLES** (Sections 1-8)
- Language-agnostic principles that apply to any modern typed language
- Architectural patterns, abstraction guidelines, and testability principles
- Pseudo-code examples illustrating concepts without language-specific syntax
- **Use these principles when working in any language (TypeScript, Go, Rust, Java, etc.)**

**PART 2: PYTHON-SPECIFIC IMPLEMENTATION RULES** (Sections 9-14)
- Concrete Python implementations of Part 1 principles
- Python-specific tools: NewType, Pydantic, ABC, type hints
- Actual Python code examples with full syntax
- **Use these rules when writing Python code in this project**

**When adapting to other languages:**
1. Follow Part 1 principles (they're universal)
2. Use your language's equivalents for Part 2 tools:
   - Type safety → TypeScript interfaces, Go struct tags, Rust types
   - Schemas → JSON Schema, Protocol Buffers, language-specific validation libraries
   - Configuration → Language-specific config libraries (Viper for Go, config crates for Rust)
   - Interfaces → Language-specific abstraction mechanisms (interfaces, traits, protocols)

---

# PART 1: FUNDAMENTAL SOFTWARE DEVELOPMENT PRINCIPLES

## 1. Collaborative Development

**IMPORTANT**: This is a collaborative project with multiple developers and AI agents working together.

### Git Operations
- **Always check git status** before committing to understand what others have changed
- **Never force push** without explicit approval
- **Review uncommitted changes** - other developers may have work in progress
- **Respect existing patterns** - if code follows a certain style, maintain it
- **Check git log** before major refactoring to see recent changes by others
- **Coordinate on shared files** - especially core modules like configuration, types

### Code Changes
- **Read existing code first** - understand the intent before modifying
- **Preserve existing functionality** - don't break what works
- **Follow established patterns** - maintain consistency with existing code style
- **Check for parallel work** - look for recent commits or staged changes
- **Document breaking changes** - especially in shared utilities

When in doubt about existing work or patterns, ask first before making changes.

---

## 2. Core Development Principles

### 2.1 Type Safety (Language-Agnostic)

**Zero untyped data structures in business logic:**
- All dictionaries/maps with static keys must have defined schemas
- Storage/database layer may return untyped structures from raw queries
- **Terminate untyped data at boundaries** - convert to typed schemas immediately
- Never pass untyped structures into business logic
- All function parameters and return types must be explicitly typed

**Strong domain types:**
- Create distinct types for domain identifiers (not just `string` or `int`)
- Example: `UserId`, `EntityName`, `ItemIndex` are distinct types, not aliases
- Prevents mixing semantically different values of the same primitive type

**Modern type systems:**
- Use language's modern type syntax (not legacy compatibility types)
- Example: Native generics, union types, optional types

**Domain boundaries:**
- Bad types (untyped, `Any`, `unknown`, `interface{}`) terminate at storage/client boundaries
- Business logic is always strictly typed
- Convert at the boundary, never inside core logic

**Explicit interfaces over structural typing:**
- Use explicit interface definitions (nominal typing)
- Avoid structural typing where it weakens type safety
- Implementations must explicitly declare interface adherence
- **Note for TypeScript:** TypeScript uses structural typing by default. To approximate nominal typing, use branded types (e.g., `type UserId = string & { __brand: "UserId" }`) or explicit named contracts with class implementations

**Shared business logic abstraction:**
- When multiple implementations share >50% logic, extract to base class/trait
- Base provides shared methods, subclasses override only abstract methods
- Provides type safety + code reuse

### 2.2 Configuration Management Principles

**Schema-based configuration:**
- Define configuration as typed schemas, not raw key-value maps
- Validate configuration at load time
- Use configuration validation libraries

**Component-specific configuration:**
- Each major component has its own configuration schema
- Configuration composed from component configs

**Explicit instantiation:**
- Configuration must be visible at top-level/entry points
- Never hide configuration loading deep in call stacks

### 2.3 Abstraction Guidelines

**Challenge unnecessary abstractions:**
- Don't create interfaces when only one implementation exists
- Don't build factories that produce only one type
- Prefer concrete types when no polymorphism needed

**When to abstract:**
- Use interfaces when you need polymorphism (multiple implementations)
- Extract to base class only when sharing >50% logic
- Otherwise, duplication is clearer

**No thin wrappers:**
- Avoid convenience methods that just delegate without adding value
- Expose underlying components directly when appropriate

### 2.4 Code Organization for Testability

**Separate resource creation from business logic:**
- Makes testing without external dependencies possible
- Entry points create resources (databases, clients, external services)
- Business functions receive resources as parameters
- Tests pass fake/mock implementations

**Dependency injection pattern:**
- Functions receive dependencies as parameters
- Never create resources inside business logic
- Clear separation: entry points create, business logic uses

**Shared utilities:**
- Extract common patterns to utility modules
- Reusable code across modules in dedicated utility directories

### 2.5 Schema Boundaries

**Storage schemas:**
- Co-located with database/storage operations
- Define structure of persisted data

**Business schemas:**
- Under each module's schema definitions
- Define structure of domain models

**Rule: Any function returning structured data must use typed schema**

**Database interactions:**
- Use typed schemas, not untyped maps

### 2.6 Data Architecture

**Security/access control:**
- All data has access control metadata when applicable
- Type-safe identifiers throughout the system

### 2.7 LLM Integration

When integrating LLM/AI services:
- **Prompts in files** - use template files, avoid inline prompt strings
- **Avoid duplicating context** - in follow-up messages
- **Manage token limits** - explicitly handle context window constraints

### 2.8 Code Organization

**DRY principle:**
- Extract shared helpers to utility modules
- No repetition - common patterns go to utilities

**Artifacts separation:**
- Console output and generated artifacts in separate modules
- Keep business logic clean from output formatting

**Helper naming conventions:**
- `_create_*` for factory functions
- `_normalize_*` for type conversions
- `_build_*` for complex object construction

**Test doubles location:**
- In-memory fakes, mocks, stubs belong in test directories
- NEVER place test doubles in source code directories

### 2.9 Testing Strategy (High-Level)

**Test doubles:**
- Use inheritance-based fakes/stubs, not mocking frameworks
- Subclass storage/service classes for tests

**Testability first:**
- Business logic must be testable without external dependencies
- Core logic should achieve high coverage without hitting real databases/APIs

**Coverage targets:**
- Focus on public APIs and business logic
- Aim for high coverage (e.g., 90%) of critical paths

### 2.10 Error Handling Principles

**Never silence errors:**
- No bare catch-all exception handlers
- Always log context before re-raising or returning errors

**Validation at boundaries:**
- Use schema validation for data contracts
- Validate input at system boundaries

**Error propagation:**
- Return error objects in result schemas when appropriate
- Include error context for debugging (error field in response schemas)

**Logging:**
- Log before re-raising exceptions
- Include context for debugging

### 2.11 Database Operations

**Resource management:**
- All storage classes implement proper resource cleanup
- Use language's resource management patterns (RAII, defer, context managers)

**Migrations:**
- Use migration tools
- Run migrations at application startup
- Migrations must be idempotent (safe to run multiple times)

### 2.12 Documentation

**Standard documentation format:**
- Use consistent docstring/comment format for public functions
- Type hints/annotations serve as documentation

**Module documentation:**
- Explain purpose and key components
- Major modules should have dedicated documentation files

**Component documentation:**
- Each major component should have doc file explaining:
  - What it does and its purpose
  - How to use it and what services consume it
  - Internal architecture
  - Use cases and examples

### 2.13 Component Use Cases (Gherkin Style)

**Rule: Every component documentation should include business use cases in Gherkin/Cucumber format**

Each major component (module, service) should document its business use cases using Gherkin-style syntax. These are **semantic/business scenarios**, not technical API usage examples.

**Format:**
```gherkin
## Use Cases

### [Feature Name]

**As a** [role/persona]
**I want to** [action/goal]
**So that** [benefit/value]

#### Scenario: [Descriptive scenario name]
**Given** [initial context/preconditions]
**When** [action taken]
**Then** [expected outcome]
**And** [additional outcomes]
```

**Example:**
```gherkin
## Use Cases

### Content Deduplication

**As a** system administrator
**I want to** skip processing duplicate items
**So that** storage costs are minimized and processing is efficient

#### Scenario: Exact duplicate upload
**Given** an item with hash "abc123" already exists in the system
**When** a user uploads an item with identical content
**Then** the system links the user to the existing item
**And** no re-processing occurs
```

**Guidelines:**
- Use roles from project personas: Admin, User, System (automated)
- Focus on **business value**, not implementation details
- Scenarios should be testable (map to unit/integration tests)
- Include both happy path and edge cases
- Keep scenarios independent (no dependencies between them)

---

## 3. Abstraction and Interface Guidelines

### 3.1 When to Use Interfaces

**Create interfaces when:**
- You have multiple implementations with shared behavior
- You need polymorphism (different types, same interface)
- Testing requires substituting implementations

**Don't create interfaces when:**
- Only one implementation exists
- No polymorphism needed
- Adding complexity without benefit

### 3.2 Interface Design Principles

**Complete interfaces:**
- Interface should declare ALL public methods needed by consumers
- Implementations should ONLY implement methods from the interface
- No implementation-specific public methods outside the interface

**Example (pseudo-code):**
```
// ❌ BAD - Implementation adds methods not in interface
interface Repository {
  function get(id: string): User
  function save(user: User): void
}

class UserRepository implements Repository {
  function get(id: string): User { ... }
  function save(user: User): void { ... }

  // ❌ VIOLATION - Not declared in interface
  function getByEmail(email: string): User | null { ... }
}
```

**Correct solution - Extend the interface:**
```
// ✅ GOOD - Extend the interface
interface Repository {
  function get(id: string): User
  function save(user: User): void
  function getByEmail(email: string): User | null  // Add to interface
}

class UserRepository implements Repository {
  function get(id: string): User { ... }
  function save(user: User): void { ... }
  function getByEmail(email: string): User | null { ... }  // Now in interface
}
```

**Private/helper methods are acceptable:**
```
// ✅ GOOD - Private methods allowed
class UserRepository implements Repository {
  function get(id: string): User {
    return this._fetchFromDb(id)
  }

  function save(user: User): void {
    this._validate(user)
    this._writeToDb(user)
  }

  private function _fetchFromDb(id: string): User { ... }  // ✅ Private helper
  private function _validate(user: User): void { ... }      // ✅ Private helper
}
```

### 3.3 All Interface Implementations Must Have Tests

**If a class implements an interface, ALL implementations must be covered by tests.**

```
// If these exist:
class SqlUserRepository implements Repository { ... }
class MongoUserRepository implements Repository { ... }
class InMemoryUserRepository implements Repository { ... }

// Then ALL must have tests:
tests/unit/repositories/test_sql_user_repository.*
tests/unit/repositories/test_mongo_user_repository.*
tests/unit/repositories/test_in_memory_user_repository.*
```

No untested implementations allowed.

### 3.4 Type Checking Usage - Only for Routing/Strategy Pattern

**Type checking (instanceof/typeof/type guards) is ONLY allowed for routing/dispatching**

**Allowed usage - Strategy pattern for routing:**
```
// ✅ GOOD - Strategy pattern for message routing
function routeMessage(message: Message): string {
  // Route message to appropriate topic based on type
  if (message is UserCreatedMessage) {
    return "users.created"
  } else if (message is OrderPlacedMessage) {
    return "orders.placed"
  } else if (message is PaymentProcessedMessage) {
    return "payments.processed"
  } else {
    throw Error("Unknown message type")
  }
}

// ✅ GOOD - Dispatching to different handlers
function handleEvent(event: Event): void {
  // Dispatch event to specific handler
  if (event is UserEvent) {
    return handleUserEvent(event)
  } else if (event is OrderEvent) {
    return handleOrderEvent(event)
  } else if (event is SystemEvent) {
    return handleSystemEvent(event)
  }
}
```

**NOT allowed - Checking type to call different methods:**
```
// ❌ BAD - Using type checking to pick methods
function processItem(item: Item): void {
  if (item is Book) {
    item.readPages()      // Specific to Book
  } else if (item is Movie) {
    item.playVideo()      // Specific to Movie
  } else if (item is Song) {
    item.playAudio()      // Specific to Song
  }
}

// ✅ GOOD - Define interface instead
interface Playable {
  function play(): void
}

class Book implements Playable {
  function play(): void {
    this.readPages()
  }
}

class Movie implements Playable {
  function play(): void {
    this.playVideo()
  }
}

class Song implements Playable {
  function play(): void {
    this.playAudio()
  }
}

function processItem(item: Playable): void {
  item.play()  // Polymorphism, no type checking needed
}
```

### 3.5 No Type Checking to Peek Inside Interfaces

**Never use type checking to access implementation-specific methods.**

```
// ❌ BAD - Peeking inside interface
function getUser(repo: Repository, id: string): User {
  user = repo.get(id)

  // ❌ VIOLATION - Checking implementation type
  if (repo is SqlRepository) {
    // ❌ Accessing method not in interface
    repo.optimizeQuery()
  }

  return user
}

// ✅ GOOD - If you need it, add to interface
interface Repository {
  function get(id: string): User
  function save(user: User): void
  function optimize(): void  // Add to interface
}

function getUser(repo: Repository, id: string): User {
  user = repo.get(id)
  repo.optimize()  // Now it's part of the contract
  return user
}
```

### 3.6 Summary: Type Checking Rules

**ONLY allowed:**
- ✅ Routing/dispatching (Strategy pattern): route message to topic based on type
- ✅ Type-based branching to different functions: `if (x is TypeA) { handleA(x) }`

**NEVER allowed:**
- ❌ Checking type to call implementation-specific methods
- ❌ Peeking inside interfaces to access non-interface methods
- ❌ Using type checking when polymorphism/interface would work

**When you want type checking to call different methods → Define an interface instead**

---

## 4. Testability by Design

### 4.1 Separate Resource Creation from Business Logic

**CRITICAL: Business logic must be testable without external dependencies**

This principle enables:
- Testing core logic with fake/mock resources
- High coverage without hitting real databases, APIs, or filesystems
- Clear separation: entry points create resources, business functions use them

**Pattern (pseudo-code):**
```
// Business logic function - accepts dependencies as parameters
function processData(
  storage: DataStorage,
  processor: DataProcessor,
  batchSize: integer
): ProcessingCounts {
  // This function is fully testable by passing fake implementations

  // Core business logic here
  items = fetchPendingItems(storage, batchSize)
  if (items is empty) {
    return ProcessingCounts()
  }

  results = processor.process(items)
  count = storage.saveResults(results)
  storage.updateStatus(results.itemIds, "processed")

  return ProcessingCounts(processed: count, stored: count)
}

// Entry point - creates and initializes all resources
function main(config: Config | null = null): void {
  // 1. Load configuration
  if (config is null) {
    appConfig = loadAppConfig()
    config = loadServiceConfig(appConfig)
  }

  // 2. Create resources (database, clients, processors)
  processor = createProcessor(config)

  // 3. Call business logic with created resources
  storage = DataStorage(config.storage.uri, config.storage.db)
  try {
    counts = processData(storage, processor, config.batchSize)

    // 4. Handle results
    print("Processed: " + counts.processed)
  } finally {
    storage.close()
  }
}
```

**Testing the business logic:**
```
function testProcessDataHappyPath() {
  // Test with fake resources - no external dependencies
  fakeStorage = FakeDataStorage(items: [...])
  fakeProcessor = FakeProcessor()

  counts = processData(fakeStorage, fakeProcessor, batchSize: 10)

  assert(counts.processed == 10)
  assert(counts.stored == 10)
}
```

**Key Points:**
- Entry points (main, CLI commands, API endpoints) create resources
- Business logic functions accept resources as parameters
- Tests pass fake implementations
- No business logic instantiates its own dependencies

---

## 5. Data Layer Organization

### 5.1 Principles

1. **Collection/table-per-module pattern** - Each database collection/table gets its own module
2. **Data layer managers own all DB operations** - Return typed schemas, never untyped maps
3. **Coordination functions for multi-collection operations** - When operations span multiple collections, write explicit coordination functions
4. **No thin wrappers** - Avoid convenience methods that just delegate without adding value
5. **Schema co-location** - Each collection's schemas live with its operations

### 5.2 The No Thin Wrappers Principle

**Problem:** Thin wrappers add indirection without value:
```
// ❌ Bad - thin wrapper that just delegates
class DataStorage {
  function claimItems(limit: integer): list[Item] {
    return this.items.claimForProcessing(limit: limit)
  }
}
```

**Solution:** Expose collection managers directly:
```
// ✅ Good - direct access to collection manager
storage.items.claimForProcessing(limit: 100)
storage.items.updateStatus(itemId, status)
storage.users.findByStatus(UserStatus.ACTIVE)
```

**Exception:** Keep orchestration methods that coordinate multiple collections:
```
// ✅ Good - genuine orchestration across collections
function storeItemsAndUpdateUser(
  userId: string,
  items: list[ItemPayload]
): list[string] {
  // Inserts items AND updates user status
  itemIds = this.items.insertMany(userId, items)
  if (itemIds is not empty) {
    this.users.updateStatus(userId, UserStatus.HAS_ITEMS)
  }
  return itemIds
}
```

---

## 6. Naming Conventions

### 6.1 Type Boundaries

**Rule: Variable names must distinguish library types from domain types**

```
// ❌ Bad - confusing
function processData(elements: list[Element]): list[Data] {
  items = []  // What type?
  for element in elements {
    item = transform(element)  // Library or domain?
    items.append(item)
  }
}

// ✅ Good - clear boundaries
function processData(rawElements: list[RawElement]): list[DomainData] {
  // Convert raw elements to domain data
  domainItems: list[DomainData] = []
  for rawElement in rawElements {
    domainItem = DomainData(
      content: rawElement.text,
      metadata: rawElement.meta
    )
    domainItems.append(domainItem)
  }
  return domainItems
}
```

### 6.2 Helper Functions

**Naming patterns:**
- `_create_*` - factory functions
- `_normalize_*` - type conversions
- `_build_*` - complex object construction
- `_validate_*` - validation helpers

---

## 7. Error Handling

### 7.1 Validation Errors

Use schema validation at boundaries:

```
// Pseudo-code
schema Entity {
  name: string
  type: string

  validator name, type:
    if (value is empty or value is whitespace) {
      raise Error("Cannot be empty")
    }
    return value.strip().uppercase()
}

try {
  entity = Entity(name: "test", type: "org")
} catch ValidationError as e {
  log.error("Invalid entity: " + e)
}
```

### 7.2 Never Silence Errors

```
// ❌ Bad - bare catch-all
try {
  processData()
} catch {  // Catches everything
  // Silent - no logging, no re-raise
}

// ❌ Bad - silent catch
try {
  processData()
} catch Exception {  // Silent catch
  // No logging, no action
}

// ✅ Good - log and handle appropriately
try {
  processData()
} catch ValueError as e {
  log.error("Invalid data: " + e)
  throw  // Re-raise
} catch Exception as e {
  log.error("Unexpected error: " + e)
  return Result(error: e.toString())
}
```

---

## 8. Fundamental Review Checklist

Before committing code in any language:

**Type Safety:**
- [ ] No untyped data structures (no `Any`, `unknown`, `interface{}`, etc.)
- [ ] Strong domain types for identifiers (not primitive string/int)
- [ ] Modern type syntax for your language
- [ ] All function parameters and return types explicitly typed

**Architecture:**
- [ ] Business logic testable without external dependencies
- [ ] Dependencies passed as parameters (not created internally)
- [ ] Resources created at entry points, not in business logic
- [ ] No unnecessary abstractions (interfaces with single implementation)

**Interfaces:**
- [ ] Interface implementations have no public methods beyond the interface
- [ ] All interface implementations have tests
- [ ] Type checking used ONLY for routing/dispatching (Strategy pattern)
- [ ] No type checking to peek inside interfaces

**Error Handling:**
- [ ] No silent error catching
- [ ] Validation at boundaries using schemas
- [ ] Context logged before re-raising errors

**Documentation:**
- [ ] Docstrings/comments for all public functions
- [ ] Module documentation explaining purpose and architecture
- [ ] Component use cases documented in Gherkin style

**Testing:**
- [ ] Tests pass with high coverage target
- [ ] Core business logic tested with fake implementations
- [ ] No external dependencies in unit tests

---

# PART 2: PYTHON-SPECIFIC IMPLEMENTATION RULES

This section provides concrete Python implementations of the principles from Part 1.

---

## 9. Python Type System

### 9.1 Type Safety Rules

**Zero `Any` or `object` types in business logic:**
- All dict shapes are Pydantic schemas
- **Exception**: Storage layer can return `dict[KeyType, Any]` from raw DB queries
- **Rule**: `Any` and `object` must be terminated at storage layer - convert to Pydantic schemas immediately
- **Never leak `Any` or `object` into business logic** - all parameters and return types must use Pydantic schemas
- **Storage writes accept Pydantic models** - storage methods convert to dict internally via `model_dump()`

**Zero `# type: ignore`:**
- Fix type errors properly
- **Exception**: `# type: ignore[type-arg]` is allowed for third-party storage types at the edge of application logic

**NewType for domain IDs:**
- All IDs get NewType aliases in `src/utils/types.py`
- Example: `UserId = NewType("UserId", str)`

**Modern syntax:**
- Python 3.10+ types (`list[str]`, `|` not `Union`)

**Always use NewType, never TypeAlias:**
- Provides stronger type checking

**Never use `TYPE_CHECKING`:**
- Always import types directly, no conditional imports for type hints

**NEVER use Protocol - ABC only:**
- **Rule**: NEVER use `typing.Protocol` anywhere in this project
- **Use ABC (Abstract Base Class)** for all interfaces
- **Rationale**: Protocol weakens type safety and allows structural typing - we want explicit inheritance
- **No exceptions** - Not for internal code, not for external boundaries, nowhere

**ABC for shared business logic:**
- **Rule**: When multiple implementations share significant logic (>50%), extract to ABC
- **Pattern**: Base class in `base.py`, implementations override abstract methods only
- **Rationale**: ABC provides type safety + code reuse; subclasses only implement specific methods

### 9.2 NewType vs TypeAlias

**Rule: Always use NewType, never TypeAlias**

NewType provides type safety and prevents mixing different semantic types:

```python
# ✅ Good - NewType prevents mixing
from typing import NewType

ChunkId = NewType("ChunkId", str)
EntityName = NewType("EntityName", str)

chunk_id: ChunkId = ChunkId("123")
entity_name: EntityName = EntityName("ACME")
# chunk_id = entity_name  # ❌ mypy error!

# ❌ Bad - TypeAlias allows mixing
from typing import TypeAlias

ChunkId: TypeAlias = str
EntityName: TypeAlias = str

chunk_id: ChunkId = "123"
chunk_id = entity_name  # ✅ No error, but semantically wrong
```

### 9.3 ABC Pattern for Shared Business Logic

When multiple implementations share significant logic, extract to an Abstract Base Class:

```python
# ✅ Good - ABC base class with shared logic
from abc import ABC, abstractmethod
from typing import Generic, TypeVar

ItemT = TypeVar("ItemT", bound=BaseModel)

class BaseOperations(ABC, Generic[ItemT]):
    """Abstract base class for common operations."""

    COLLECTION_NAME: str  # Subclass defines

    @abstractmethod
    def _validate_item(self, doc: dict) -> ItemT:
        """Convert raw document to typed schema."""
        ...

    # Shared implementation - not abstract
    def get_item(self, item_id: str) -> ItemT | None:
        result = self._collection.find_one({"_id": item_id})
        return self._validate_item(result) if result else None

# ✅ Good - Subclass only overrides abstract methods
class UserOperations(BaseOperations[User]):
    COLLECTION_NAME = "users"

    def _validate_item(self, doc: dict) -> User:
        return User.model_validate(doc)

# ❌ Bad - Each class duplicates the implementation
class UserOps:
    def get_item(...):  # Duplicated implementation
        result = self._collection.find_one({"_id": item_id})
        return self._validate_item(result) if result else None

class ProductOps:
    def get_item(...):  # Same code duplicated
        result = self._collection.find_one({"_id": item_id})
        return self._validate_item(result) if result else None
```

**Rule: Always use ABC for interfaces, NEVER Protocol**

### 9.4 When to Create NewType

**Rule: Create NewType when value is used as key/ID or has semantic meaning**

- `str` → `UserId` when used as: `dict[UserId, UserData]`
- `str` → `EntityName` when used as: `list[EntityName]`
- `int` → `ItemIndex` when used as identifier
- `float` → No NewType needed if just a calculation result

### 9.5 Type Organization

**All NewType aliases live in `src/utils/types.py`** (single source of truth):

```python
from typing import NewType

# Domain identifiers
UserId = NewType("UserId", str)
ItemId = NewType("ItemId", str)

# Entity types
EntityName = NewType("EntityName", str)
EntityType = NewType("EntityType", str)
```

### 9.6 Modern Type Syntax

```python
# ✅ Good - Python 3.10+ syntax
def process(items: list[str]) -> dict[str, int]:
    ...

def fetch(config: Config | None = None) -> list[Item]:
    ...

# ❌ Bad - old syntax
from typing import List, Dict, Optional

def process(items: List[str]) -> Dict[str, int]:
    ...
```

### 9.7 Python Interface Usage Rules

**CRITICAL: Strict rules for ABC implementations and isinstance usage**

**IMPORTANT: This project NEVER uses Protocol - ABC only for all interfaces**

#### Rule 1: Interface Implementations Must Be Complete

If a class inherits from an ABC, it must ONLY implement methods from that interface.

```python
# ❌ BAD - Adding public methods beyond interface
class UserRepository(RepositoryABC):
    def get(self, id: str) -> User:
        ...

    def save(self, user: User) -> None:
        ...

    # ❌ VIOLATION - New public method not in interface
    def get_by_email(self, email: str) -> User | None:
        ...
```

**Why this is wrong:**
- ABC doesn't declare `get_by_email`
- Other implementations won't have this method
- Code using `RepositoryABC` can't call `get_by_email` without casting
- Interface is incomplete

**Correct solution - Extend the ABC:**

```python
# ✅ GOOD - Extend the ABC
from abc import ABC, abstractmethod

class RepositoryABC(ABC):
    @abstractmethod
    def get(self, id: str) -> User: ...

    @abstractmethod
    def save(self, user: User) -> None: ...

    @abstractmethod
    def get_by_email(self, email: str) -> User | None: ...  # Add to ABC

class UserRepository(RepositoryABC):
    def get(self, id: str) -> User:
        ...

    def save(self, user: User) -> None:
        ...

    def get_by_email(self, email: str) -> User | None:
        ...  # Now it's part of the interface
```

**Private/helper methods are OK:**

```python
# ✅ GOOD - Private methods are allowed
class UserRepository(RepositoryABC):
    def get(self, id: str) -> User:
        return self._fetch_from_db(id)

    def save(self, user: User) -> None:
        self._validate(user)
        self._write_to_db(user)

    def _fetch_from_db(self, id: str) -> User:  # ✅ Private helper
        ...

    def _validate(self, user: User) -> None:  # ✅ Private helper
        ...
```

#### Rule 2: All Interface Implementations Must Have Tests

**If a class implements an ABC, ALL implementations must be covered by tests.**

```python
# If these exist:
class SqlUserRepository(RepositoryABC): ...
class MongoUserRepository(RepositoryABC): ...
class InMemoryUserRepository(RepositoryABC): ...

# Then ALL must have tests:
tests/unit/repositories/test_sql_user_repository.py
tests/unit/repositories/test_mongo_user_repository.py
tests/unit/repositories/test_in_memory_user_repository.py
```

No untested implementations allowed.

#### Rule 3: isinstance Usage - Only for Routing/Strategy Pattern

**isinstance is ONLY allowed for routing/dispatching based on type (Strategy pattern)**

```python
# ✅ GOOD - Strategy pattern for message routing
def route_message(message: Message) -> str:
    """Route message to appropriate topic based on schema type."""
    if isinstance(message, UserCreatedMessage):
        return "users.created"
    elif isinstance(message, OrderPlacedMessage):
        return "orders.placed"
    elif isinstance(message, PaymentProcessedMessage):
        return "payments.processed"
    else:
        raise ValueError(f"Unknown message type: {type(message)}")

# ✅ GOOD - Dispatching to different handlers
def handle_event(event: Event) -> None:
    """Dispatch event to specific handler."""
    if isinstance(event, UserEvent):
        return handle_user_event(event)
    elif isinstance(event, OrderEvent):
        return handle_order_event(event)
    elif isinstance(event, SystemEvent):
        return handle_system_event(event)
```

**isinstance is NOT allowed for calling different methods based on type**

```python
# ❌ BAD - Using isinstance to pick methods
def process_item(item: Item) -> None:
    if isinstance(item, Book):
        item.read_pages()  # Specific to Book
    elif isinstance(item, Movie):
        item.play_video()  # Specific to Movie
    elif isinstance(item, Song):
        item.play_audio()  # Specific to Song

# ✅ GOOD - Define ABC interface instead
from abc import ABC, abstractmethod

class PlayableABC(ABC):
    @abstractmethod
    def play(self) -> None: ...

class Book(PlayableABC):
    def play(self) -> None:
        self.read_pages()

class Movie(PlayableABC):
    def play(self) -> None:
        self.play_video()

class Song(PlayableABC):
    def play(self) -> None:
        self.play_audio()

def process_item(item: PlayableABC) -> None:
    item.play()  # Polymorphism, no isinstance needed
```

#### Rule 4: No isinstance Hacks to Peek Inside Interfaces

**Never use isinstance to check implementation type and access implementation-specific methods.**

```python
# ❌ BAD - Peeking inside interface
def get_user(repo: RepositoryABC, id: str) -> User:
    user = repo.get(id)

    # ❌ VIOLATION - Checking implementation type
    if isinstance(repo, SqlRepository):
        # ❌ Accessing method not in ABC
        repo.optimize_query()

    return user

# ✅ GOOD - If you need it, add to ABC
from abc import ABC, abstractmethod

class RepositoryABC(ABC):
    @abstractmethod
    def get(self, id: str) -> User: ...

    @abstractmethod
    def optimize(self) -> None: ...  # Add to ABC

def get_user(repo: RepositoryABC, id: str) -> User:
    user = repo.get(id)
    repo.optimize()  # Now it's part of the contract
    return user
```

#### Summary: isinstance Usage Rules

**ONLY allowed:**
- ✅ Routing/dispatching (Strategy pattern): `route_message(message)` → topic based on message type
- ✅ Type-based branching to different functions: `if isinstance(x, TypeA): handle_a(x)`

**NEVER allowed:**
- ❌ Checking type to call implementation-specific methods
- ❌ Peeking inside interfaces to access non-interface methods
- ❌ Using `isinstance` when polymorphism/interface would work

**When you want isinstance to call different methods → Define an interface instead**

---

## 10. Pydantic Schemas and Data Contracts

### 10.1 When to Create Pydantic Schemas

**Rule: Any function returning dict with static keys MUST use Pydantic schema**

```python
# ❌ Bad
def parse_response(text: str) -> Dict[str, List[Dict[str, Any]]]:
    return {"entities": [...], "relationships": [...]}

# ✅ Good
def parse_response(text: str) -> ParsedData:
    return ParsedData(
        entities=[Entity(...)],
        relationships=[Relationship(...)]
    )
```

### 10.2 Handling `Any` from Storage Layer

**Rule: Storage can return `Any`, but must be converted at accessor/service boundary**

```python
# ✅ Storage layer - OK to return Any from raw DB
class DatabaseStorage:
    def get_entity(self, id: str) -> dict[str, Any] | None:
        """Raw database query returns untyped dict."""
        result = self.db.find_one({"id": id})
        return result if result else None

# ✅ Service/Repository - Convert Any to Pydantic
class EntityService:
    def __init__(self, storage: DatabaseStorage):
        self.storage = storage

    def get_entity(self, id: EntityId) -> Entity | None:
        """Service converts dict[str, Any] to typed schema."""
        raw_data = self.storage.get_entity(id)
        if not raw_data:
            return None

        # Convert dict[str, Any] → Pydantic schema
        return Entity(
            id=EntityId(str(raw_data["id"])),
            name=str(raw_data["name"]),
            type=EntityType(str(raw_data["type"])),
        )

# ❌ Bad - Business logic receives Any
def process_entity(entity_data: dict[str, Any]) -> Result:
    # Don't do this - business logic should never see Any
    pass

# ✅ Good - Business logic receives typed schema
def process_entity(entity: Entity) -> Result:
    # Business logic only works with Pydantic schemas
    return Result(name=entity.name, type=entity.type)
```

**Key principles:**
1. Storage layer returns `dict[str, Any]` from raw DB queries (acceptable)
2. Service/repository layer converts `Any` → Pydantic schemas (required)
3. Business logic only receives typed Pydantic schemas (enforced)
4. Never pass `dict[str, Any]` to business logic

### 10.3 Schema Organization

```
src/
├── services/
│   ├── user_service/
│   │   ├── schemas.py       # Service-specific models
│   │   ├── config.py        # Service configuration
│   │   └── service.py       # Service implementation
│   └── product_service/
│       └── ...
├── storage/
│   ├── database/
│   │   ├── users/                      # Collection module
│   │   │   ├── __init__.py             # Re-exports
│   │   │   ├── schema.py               # User, UserMetadata
│   │   │   └── operations.py           # UserOperations class
│   │   └── products/
│   │       └── ...
└── utils/
    └── types.py                        # ALL NewType aliases
```

**Rules:**
- **No catch-all re-export modules** - always import from explicit source module
- **Collection modules** with operations use `storage/<backend>/<collection>/` pattern
- NewType aliases ONLY in `src/utils/types.py`

### 10.4 Schema Best Practices

```python
from pydantic import BaseModel, Field, field_validator

class DataItem(BaseModel):
    """Container for processed data."""

    items: list[Item] = Field(default_factory=list)
    metadata: dict[str, str] = Field(default_factory=dict)

    @property
    def is_empty(self) -> bool:
        return len(self.items) == 0

    @field_validator("items")
    @classmethod
    def validate_items(cls, v: list[Item]) -> list[Item]:
        # Custom validation
        return v
```

**Guidelines:**
- Use `Field(default_factory=list)` for lists, never `Field(default=[])`
- Add `@property` methods for computed values
- Add `@classmethod` factories for construction patterns
- Validate with `@field_validator`

---

## 11. Python Configuration Management

### 11.1 Configuration Architecture

Components should have their own config modules:

```
src/services/user_service/config.py
src/services/product_service/config.py
```

### 11.2 Config Module Pattern

```python
from pydantic import BaseModel
from src.config import AppConfig, StorageConfig

class ServiceConfig(BaseModel):
    """Configuration for this specific service."""
    storage: StorageConfig
    batch_size: int = 100

def load_service_config(app_config: AppConfig) -> ServiceConfig:
    """Build service config from app config (required parameter).

    Args:
        app_config: Application configuration (REQUIRED)

    Returns:
        ServiceConfig for this service
    """
    return ServiceConfig(
        storage=app_config.storage,
        batch_size=app_config.batch_size,
    )
```

---

## 12. Python Testing Patterns

**See [Test Style Guide](test-style.md) for detailed testing standards.**

### 12.1 Core Testing Principles

- **In-memory fakes only** - subclass storage classes for tests
- **NO unittest.mock** - inheritance-based test doubles only
- **Test business logic directly** - core logic must be testable without external dependencies
- **90% coverage target** - focus on public APIs and business logic

### 12.2 Testability Pattern

```python
def process_data(
    storage: DataStorage,
    processor: DataProcessor,
    batch_size: int,
) -> ProcessingCounts:
    """Business logic function - accepts dependencies as parameters.

    This function is fully testable by passing fake implementations.
    """
    # Core business logic here
    items = fetch_pending_items(storage, batch_size)
    if not items:
        return ProcessingCounts()

    results = processor.process(items)
    count = storage.save_results(results)
    storage.update_status(results.item_ids, "processed")

    return ProcessingCounts(processed=count, stored=count)


def main(config: Config | None = None):
    """Entry point - creates and initializes all resources.

    Args:
        config: Configuration. If None, loaded from default location.
    """
    # 1. Load configuration
    if config is None:
        from src.config import load_app_config
        app_config = load_app_config()
        config = load_service_config(app_config)

    # 2. Create resources (database, clients, processors)
    processor = create_processor(config)

    # 3. Call business logic with created resources
    from src.storage import DataStorage
    with DataStorage(config.storage.uri, config.storage.db) as storage:
        counts = process_data(storage, processor, config.batch_size)

    # 4. Handle results
    print(f"Processed: {counts.processed}")
```

**Testing the business logic:**

```python
def test_process_data_happy_path():
    """Test with fake resources - no external dependencies."""
    fake_storage = FakeDataStorage(items=[...])
    fake_processor = FakeProcessor()

    counts = process_data(fake_storage, fake_processor, batch_size=10)

    assert counts.processed == 10
    assert counts.stored == 10
```

---

## 13. Python Error Handling

### 13.1 Pydantic Validation Errors

Use Pydantic validation:

```python
from pydantic import BaseModel, field_validator, ValidationError

class Entity(BaseModel):
    name: str
    type: str

    @field_validator("name", "type", mode="before")
    @classmethod
    def uppercase_and_strip(cls, value: str) -> str:
        if not value or not value.strip():
            raise ValueError("Cannot be empty")
        return value.strip().upper()

try:
    entity = Entity(name="test", type="org")
except ValidationError as e:
    logger.error(f"Invalid entity: {e}")
```

### 13.2 Never Silence Errors

```python
# ❌ Bad
try:
    process_data()
except:  # Bare except
    pass

# ❌ Bad
try:
    process_data()
except Exception:  # Silent catch
    pass

# ✅ Good
try:
    process_data()
except ValueError as e:
    logger.error(f"Invalid data: {e}")
    raise
except Exception as e:
    logger.error(f"Unexpected error: {e}")
    return Result(error=str(e))
```

---

## 14. Python-Specific Review Checklist

Before committing Python code:

**Python Type System:**
- [ ] `uv run mypy .` passes with 0 errors
- [ ] No `Dict[str, Any]` return types with static keys (use Pydantic)
- [ ] No `# type: ignore` comments (except allowed exceptions: `type-arg` at edges)
- [ ] All NewTypes in `src/utils/types.py`
- [ ] Modern type hints (`list` not `List`, `|` not `Union`)
- [ ] No `Protocol` usage (ABC only)
- [ ] ABC used when sharing >50% logic between implementations

**Pydantic Schemas:**
- [ ] Pydantic schemas for all complex return types
- [ ] `Any` terminated at storage boundary (converted to schemas)
- [ ] `Field(default_factory=list)` for list defaults
- [ ] `@field_validator` for custom validation

**Code Quality:**
- [ ] `uv run ruff check .` passes with 0 errors
- [ ] Docstrings for all public functions
- [ ] No bare `except:` clauses

**Testing:**
- [ ] Tests pass with 90% coverage target
- [ ] Business logic testable with fake implementations
- [ ] No `unittest.mock` usage (inheritance-based fakes only)

**Storage:**
- [ ] Storage classes use context managers (`__enter__`/`__exit__`)

**Interface Rules:**
- [ ] Interface implementations have no public methods beyond the interface
- [ ] All interface implementations have tests
- [ ] `isinstance()` used ONLY for routing/dispatching (Strategy pattern)
- [ ] No `isinstance()` peeking inside interfaces

---

## Questions?

When in doubt:
1. Check existing code for patterns
2. Run `uv run mypy .` - catches most issues
3. Ask: "Can I test this without external dependencies?"
4. Ask: "Would this be clear in 6 months?"
5. Prefer explicit over implicit
6. Prefer type safety over convenience
7. Challenge unnecessary abstractions
