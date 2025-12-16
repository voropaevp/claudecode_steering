# Architecture Guide

**Status:** This document will be populated as the system architecture develops.

## System Overview

[TBD - High-level description of the system and its purpose]

## Component Layout

**Expected structure:**
```
src/
├── config.py              # [TBD] Application configuration
├── utils/
│   └── types.py          # [TBD] NewType definitions
├── services/             # [TBD] Business logic modules
│   └── {service}/
│       ├── doc.md        # Service documentation
│       ├── schemas.py    # Service-specific Pydantic models
│       ├── config.py     # Service configuration
│       └── service.py    # Service implementation
└── storage/              # [TBD] Data persistence layer
    └── database/
        └── {collection}/
            ├── schema.py      # Storage schemas
            └── operations.py  # Database operations
```

## Public Contracts

[TBD - List of major APIs, services, and their purposes]

## Service Interactions

[TBD - How components communicate and depend on each other]

## Design Patterns

The following patterns are enforced by `docs/code-style.md`:

- **Testable business logic** - Dependencies passed as parameters, not created internally
- **ABC for shared logic** - When >50% code is reused
- **NewType for domain IDs** - All IDs use NewType in `src/utils/types.py`
- **Pydantic schemas** - For all data contracts
- **Context managers** - For all resources (DB, files, clients)

## Adding New Components

[TBD - Guidelines for extending the system]

See `docs/code-style.md` for detailed coding standards.
