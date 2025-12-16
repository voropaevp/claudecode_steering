# Test Style Guide

This document defines testing standards, patterns, and best practices for this project.

**Related documentation:**
- [Code Style Guide](code-style.md) - General coding standards
- [Architecture](architecture.md) - System architecture

---

## How to Use This Guide

This guide is organized into two parts:

**PART 1: FUNDAMENTAL TESTING PRINCIPLES** - Language-agnostic testing principles that apply to any programming language. These are the core concepts, patterns, and philosophies that guide our testing approach.

**PART 2: PYTHON-SPECIFIC TESTING IMPLEMENTATION** - Concrete Python implementations using pytest, coverage tools, and Python-specific patterns. If you're working in another language, adapt these patterns to your language's testing framework.

**Adapting to Other Languages:**
- Read Part 1 to understand the fundamental principles
- Replace Python examples with equivalent patterns in your target language
- For example, "no unittest.mock" becomes "no mocking frameworks" in general
- The fake/test double pattern using explicit fakes (inheritance or interface implementation) works across all languages
- Coverage targets and test organization principles remain the same

---

## PART 1: FUNDAMENTAL TESTING PRINCIPLES

### 1. Core Testing Principles

#### 1.1 No Mocking Frameworks (Language-Agnostic)

**CRITICAL: Use explicit fake implementations, not mocking libraries**

The principle: Avoid using any mocking framework or library that allows you to create test doubles through configuration or magic. Instead, create explicit fake implementations of the contract (inheritance where available, otherwise interface implementation/composition).

**Note:** Pseudo-code syntax is illustrative; translate to your language's idioms.

```
// ❌ Bad - don't use mocking frameworks
MockService mockService = mock(Service.class);
when(mockService.generate(data)).thenReturn([...]);

// ❌ Bad - don't use dynamic patching/stubbing
stub(Service, 'generate').returns([...]);

// ✅ Good - class-based fake via inheritance
class FakeService extends Service {
    generate(data: List<String>): List<Result> {
        return data.map(d => new Result(d));
    }
}
```

#### 1.2 Why Inheritance Over Mocking

1. **Type safety** - Fakes implement the same interface, caught by static type checkers
2. **Discoverability** - IDE autocomplete and code navigation works
3. **Refactor safety** - Interface changes break fakes immediately at compile/check time
4. **Readability** - Clear what fake does vs. magic mock behavior configured in tests

#### 1.3 No Internal State Manipulation

**Never manipulate internal service states to game coverage targets.**

This is the fundamental reason why mocking frameworks are prohibited:
- Mocking internal state creates tests that pass but don't verify real behavior
- Coverage numbers become meaningless if you mock away the code being "tested"
- The test suite must be trustworthy - it should catch real bugs

```
// ❌ Bad - manipulates internal state, test passes but proves nothing
function testWithMock() {
    // Set internal cache directly via reflection/mocking
    setInternalState(storage, "_internalCache", {"fake": "data"});
    result = storage.getData();
    assert(result == {"fake": "data"});  // Of course it passes - you set it!
}

// ✅ Good - tests actual behavior with real (fake) implementation
function testWithFake() {
    fakeStorage = new FakeStorage(initialData: {"real": "data"});
    result = fakeStorage.getData();
    assert(result == {"real": "data"});  // Tests actual getData() logic
}
```

#### 1.4 Share Common Fake Classes

**Reusable fake classes reduce code duplication and ensure consistency.**

Principles:
- All fake storage classes should live in a dedicated test directory (e.g., `tests/fakes/`)
- **NEVER place fakes under production code directories** - classes like `InMemoryRepository`, `FakeStorage`, etc. are test infrastructure
- Fake classes should be well-tested themselves if complex
- When multiple tests need the same fake behavior, extract to shared fixture or helper

```
// In tests/fakes/storage.fake - shared across all tests
class FakeDataStorage extends DataStorage {
    private items: List<Item>;
    public updates: List<Update> = [];

    constructor(items: List<Item> = []) {
        // Don't call super() - avoid real connections
        this.items = items;
    }

    // ... implementation
}

// Usage in tests via fixture/helper
function createFakeStorage(): FakeDataStorage {
    return new FakeDataStorage();
}
```

#### 1.5 Bug Fixes Require Tests

**Every business logic bug must get unit test coverage before being marked as fixed.**

When you fix a bug in business logic:
1. Write a test that reproduces the bug (should fail initially)
2. Fix the bug
3. Verify the test passes
4. Commit both the fix and the test together

This ensures:
- The bug is actually fixed (not just hidden)
- The bug won't regress in the future
- The test suite grows with real-world failure cases

#### 1.6 Test Business Logic Functions

Business logic lives in orchestrator functions that can be tested without external dependencies:

```
// ✅ Test the orchestrator function directly
function testProcessingPipelineHappyPath() {
    fakeStorage = new FakeDataStorage(items: [...]);
    fakeProcessor = new FakeProcessor();

    counts = runProcessingPipeline(fakeStorage, fakeProcessor, batchSize: 10);

    assert(counts.processed == 10);
    assert(counts.stored == 10);
}
```

#### 1.7 Coverage Target (90%)

- Focus on **public APIs** and **orchestrator boundaries**
- Avoid testing tiny private helpers (use naming conventions to mark them)
- Each orchestrator function must have at least a happy path test

---

### 2. Test Organization

#### Directory Structure

```
tests/
├── unit/
│   ├── services/
│   │   ├── user_service/
│   │   │   ├── test_service       # Service tests
│   │   │   └── test_schemas       # Schema tests
│   │   └── product_service/
│   │       └── ...
│   └── storage/
│       ├── test_database
│       └── fakes                   # Shared fake implementations
├── integration/
│   └── ...
└── fixtures                        # Shared test fixtures
```

**Rules:**
- Test structure mirrors production source directory
- Each module has dedicated test file
- **Fake location decision:**
  - `tests/fixtures/` or `tests/fakes/` - Fakes used across MULTIPLE test modules
  - `tests/unit/<module>/fakes` - Fakes specific to ONE module/service
  - `tests/storage/fakes` - Storage-layer fakes (database, cache, etc.)
- Shared fixtures/helpers in dedicated directory

---

### 3. Fake/Test Double Pattern

#### In-Memory Fake Implementation Pattern

```
// In tests/fakes/storage.fake or tests/fixtures/storage
class FakeDataStorage extends DataStorage {
    private items: List<Item>;
    public updates: List<Update> = [];

    constructor(items: List<Item> = null) {
        // Don't call super() - no real database connection
        this.items = items ?? [];
    }

    getPendingItems(status: String, limit: Integer): List<Item> {
        return this.items
            .filter(item => item.status == status)
            .take(limit);
    }

    updateItemStatus(itemId: String, status: String): void {
        this.updates.add(new Update(itemId, status));
    }

    close(): void {
        // No-op for fake
    }

    // Resource management pattern (if language supports it)
    dispose(): void {
        // No-op for fake
    }
}
```

#### Using Fakes in Tests

```
// In tests/unit/services/test_pipeline
function testProcessingPipelineWithMultipleItems() {
    // Arrange
    items = [
        new Item(id: "1", content: "data 1", status: "pending"),
        new Item(id: "2", content: "data 2", status: "pending"),
    ];
    fakeStorage = new FakeDataStorage(items: items);
    fakeProcessor = new FakeProcessor();

    // Act
    counts = runProcessingPipeline(fakeStorage, fakeProcessor, batchSize: 10);

    // Assert
    assert(counts.processed == 2);
    assert(fakeStorage.updates.length == 2);
}
```

---

### 4. Running Tests

General principles for running tests:

```bash
# Run all unit tests
<test-runner> tests/ --verbose

# Run specific test file
<test-runner> tests/unit/services/test_pipeline --verbose

# Run specific test
<test-runner> tests/unit/services/test_pipeline::testHappyPath --verbose

# Run with coverage
<test-runner> tests/ --coverage --coverage-report=html

# Run tests matching pattern
<test-runner> --filter="processing and happy" --verbose

# Run with debugger on failure
<test-runner> tests/ --debug-on-failure
```

---

### 5. Coverage

#### Running Coverage

```bash
# Unit tests with coverage
<test-runner> tests/unit --coverage=src --coverage-report=html --coverage-report=summary

# View HTML report
<open-command> coverage-report/index.html

# Unit tests with threshold enforcement
<test-runner> tests/unit --coverage=src --coverage-threshold=90

# Coverage for specific module
<test-runner> tests/unit/services --coverage=src/services --coverage-report=summary
```

#### Improving Coverage

When adding coverage:
1. Focus on business logic in orchestrators first
2. Test happy paths, then edge cases
3. Prefer testing public APIs over private helpers
4. Check uncovered lines with detailed coverage report
5. Use HTML report for detailed analysis

---

### 6. How to Add New Tests

#### Checklist for New Test Files

1. [ ] Create test file mirroring production source structure
2. [ ] Import shared fixtures from test fixtures directory
3. [ ] Create or reuse fake classes for dependencies
4. [ ] Write happy path test first
5. [ ] Add edge cases (empty input, error conditions)
6. [ ] Verify 90% coverage with coverage tool

#### Checklist for New Fake Classes

1. [ ] Use explicit implementation of the contract (inherit interface or implement interface/composition)
2. [ ] Don't call parent constructor (avoid real connections)
3. [ ] Implement all methods used by the code under test
4. [ ] Store operations in collections for assertions (e.g., `updates = []`)
5. [ ] Implement resource management protocol (if applicable)
6. [ ] Add to shared test fixtures directory if reusable

---

### 7. Test Review Checklist

Before committing tests:

- [ ] No mocking frameworks or libraries used
- [ ] No dynamic patching/stubbing used
- [ ] All fakes use explicit implementations of the contract (inheritance where available, otherwise interface implementation)
- [ ] Orchestrator functions tested directly (no framework runtime needed)
- [ ] At least happy path test for each orchestrator function
- [ ] Edge cases covered (empty input, errors)
- [ ] Shared fakes in fixtures directory
- [ ] Test file mirrors production source structure
- [ ] 90% coverage target met for new code

---

## PART 2: PYTHON-SPECIFIC TESTING IMPLEMENTATION

### 1. Python Testing Rules

#### No unittest.mock, No monkeypatch

**CRITICAL: Use class-based fakes via inheritance, not mocking libraries**

```python
# ❌ Bad - don't use
from unittest.mock import Mock, patch, MagicMock
with patch('module.Service') as mock:
    mock.return_value.generate.return_value = [...]

# ❌ Bad - don't use
def test_something(monkeypatch):
    monkeypatch.setattr(...)

# ✅ Good - class-based fake
class FakeService(Service):
    def generate(self, data: list[str]) -> list[Result]:
        return [Result(data=d) for d in data]
```

#### Why Inheritance Over Mocking in Python

1. **Type safety** - Fakes implement the same interface, caught by mypy
2. **Discoverability** - IDE autocomplete works
3. **Refactor safety** - Interface changes break fakes immediately
4. **Readability** - Clear what fake does vs. magic mock behavior

#### No Internal State Manipulation in Python

```python
# ❌ Bad - manipulates internal state, test passes but proves nothing
def test_with_mock(monkeypatch):
    monkeypatch.setattr(storage, "_internal_cache", {"fake": "data"})
    result = storage.get_data()
    assert result == {"fake": "data"}  # Of course it passes - you set it!

# ✅ Good - tests actual behavior with real (fake) implementation
def test_with_fake():
    fake_storage = FakeStorage(initial_data={"real": "data"})
    result = fake_storage.get_data()
    assert result == {"real": "data"}  # Tests actual get_data() logic
```

#### Share Common Fake Classes in Python

```python
# In tests/conftest.py - shared across all tests
class FakeDataStorage:
    """Shared fake for all tests needing data storage."""

    def __init__(self, items: list[dict] | None = None):
        self.items = items or []
        self.updates: list[dict] = []

    # ... implementation

@pytest.fixture
def fake_storage():
    """Fixture providing clean FakeDataStorage instance."""
    return FakeDataStorage()
```

---

### 2. In-Memory Fake Pattern (Python)

```python
# In tests/conftest.py or tests/storage/fakes.py
class FakeDataStorage:
    """In-memory fake for testing."""

    def __init__(self, items: list[dict] | None = None):
        # Don't call super().__init__() - no real database connection
        self.items = items or []
        self.updates: list[dict] = []

    def get_pending_items(self, status: str, limit: int) -> list[dict]:
        return [item for item in self.items if item.get("status") == status][:limit]

    def update_item_status(self, item_id: str, status: str) -> None:
        self.updates.append({"item_id": item_id, "status": status})

    def close(self) -> None:
        pass  # No-op for fake

    def __enter__(self) -> FakeDataStorage:
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        pass
```

#### Using Fakes in Python Tests

```python
# In tests/unit/services/test_pipeline.py
def test_processing_pipeline_with_multiple_items():
    """Test orchestrator with fake storage."""
    items = [
        {"item_id": "1", "content": "data 1", "status": "pending"},
        {"item_id": "2", "content": "data 2", "status": "pending"},
    ]
    fake_storage = FakeDataStorage(items=items)
    fake_processor = FakeProcessor()

    counts = run_processing_pipeline(fake_storage, fake_processor, batch_size=10)

    assert counts.processed == 2
    assert len(fake_storage.updates) == 2
```

---

### 3. Python Test Examples

#### Schema Validation Tests

```python
import pytest
from pydantic import ValidationError
from src.services.schemas import Entity, Relationship

class TestEntity:
    def test_validation_uppercase(self):
        entity = Entity(name="test", type="org", description="...")
        assert entity.name == "TEST"  # Validated to uppercase

    def test_validation_error(self):
        with pytest.raises(ValidationError):
            Entity(name="", type="org", description="...")
```

#### Pipeline Tests

```python
class TestProcessingPipeline:
    def test_happy_path(self):
        fake_storage = FakeDataStorage(items=[...])
        fake_processor = FakeProcessor()

        counts = run_processing_pipeline(fake_storage, fake_processor, batch_size=10)

        assert counts.processed == 10
        assert counts.stored == 10

    def test_empty_items(self):
        fake_storage = FakeDataStorage(items=[])
        fake_processor = FakeProcessor()

        counts = run_processing_pipeline(fake_storage, fake_processor, batch_size=10)

        assert counts.processed == 0
```

---

### 4. Running Python Tests

```bash
# Run all unit tests
uv run pytest tests/ -v

# Run specific test file
uv run pytest tests/unit/services/test_pipeline.py -v

# Run specific test
uv run pytest tests/unit/services/test_pipeline.py::TestPipeline::test_happy_path -v

# Run with coverage
uv run pytest tests/ --cov=src --cov-report=html

# Run tests matching pattern
uv run pytest -k "processing and happy" -v

# Run with pdb on failure
uv run pytest tests/ --pdb
```

---

### 5. Python Coverage Tools

#### Running Coverage with pytest-cov

```bash
# Unit tests with coverage
uv run pytest tests/unit --cov=src --cov-report=html --cov-report=term-missing

# View HTML report
open htmlcov/index.html

# Unit tests with threshold enforcement
uv run pytest tests/unit --cov=src --cov-fail-under=90

# Coverage for specific module
uv run pytest tests/unit/services --cov=src/services --cov-report=term-missing
```

#### Improving Coverage in Python

When adding coverage:
1. Focus on business logic in orchestrators first
2. Test happy paths, then edge cases
3. Prefer testing public APIs over private helpers
4. Check uncovered lines with `--cov-report=term-missing`
5. Use HTML report (`htmlcov/index.html`) for detailed analysis

---

### 6. Python Test Organization

#### Directory Structure

```
tests/
├── unit/
│   ├── services/
│   │   ├── user_service/
│   │   │   ├── test_service.py      # Service tests
│   │   │   └── test_schemas.py      # Schema tests
│   │   └── product_service/
│   │       └── ...
│   └── storage/
│       ├── test_database.py
│       └── fakes.py                  # Shared fake implementations
├── integration/
│   └── ...
└── conftest.py                       # Shared fixtures
```

**Python-specific rules:**
- Test structure mirrors `src/` directory
- Each module has dedicated test file
- **Fake location decision:**
  - `tests/conftest.py` - Fakes used across MULTIPLE test modules (pytest fixtures)
  - `tests/unit/<module>/fakes.py` - Fakes specific to ONE module/service
  - `tests/storage/fakes.py` - Storage-layer fakes (database, cache, etc.)
- Shared fixtures in `conftest.py` using `@pytest.fixture` decorator

#### Checklist for New Python Test Files

1. [ ] Create test file mirroring `src/` structure (e.g., `tests/unit/services/test_user_service.py`)
2. [ ] Import shared fixtures from `conftest.py`
3. [ ] Create or reuse fake classes for dependencies
4. [ ] Write happy path test first
5. [ ] Add edge cases (empty input, error conditions)
6. [ ] Verify 90% coverage with `uv run pytest --cov=src/services`

#### Checklist for New Python Fake Classes

1. [ ] Subclass the real implementation
2. [ ] Don't call `super().__init__()` (avoid real connections)
3. [ ] Implement all methods used by the code under test
4. [ ] Store operations in lists for assertions (e.g., `self.updates = []`)
5. [ ] Implement context manager protocol (`__enter__`, `__exit__`)
6. [ ] Add to `tests/conftest.py` if reusable, with `@pytest.fixture` decorator

---

### 7. Python Test Review Checklist

Before committing Python tests:

- [ ] No `unittest.mock`, `Mock`, `MagicMock`, or `patch` usage
- [ ] No `monkeypatch` fixtures
- [ ] All fakes subclass real implementations
- [ ] Orchestrator functions tested directly (no framework runtime needed)
- [ ] At least happy path test for each orchestrator function
- [ ] Edge cases covered (empty input, errors)
- [ ] Shared fakes in `conftest.py` with `@pytest.fixture`
- [ ] Test file mirrors `src/` structure
- [ ] 90% coverage target met for new code
- [ ] Using pytest (not unittest framework)
- [ ] Type hints on fake class methods match real implementation
