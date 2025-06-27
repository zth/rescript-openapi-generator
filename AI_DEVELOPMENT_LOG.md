# AI Development Log

Brief notes on AI collaboration for each development session.

---

## Session 1: Project Setup (2025-06-27)

**Completed:** ReScript project, dependencies, CI/CD, docs, Petstore test spec

**Worked Well:**

- Parallel tool execution for efficiency
- Debugged rescript-vitest → rescript-ava migration successfully
- Comprehensive setup (4/4 tests passing, CI working)

**Could Improve:**

- Research tool stability before choosing (vitest was broken)
- Avoid over-engineering (created unnecessary templates)
- Ask about assumptions (repo naming, complexity level)

**ReScript Tooling Gaps:**

- No ecosystem discovery/package health indicators (hard to assess rescript-vitest vs rescript-ava)
- Cryptic errors when bindings generate wrong JS (Vitest.describe vs describe)
- Missing compatibility matrix for ReScript versions vs packages
- Multiple competing test frameworks without clear official recommendations

**Result:** Solid foundation ready for implementation.

---

## Session 2: OpenAPI Generator Implementation (2025-06-27)

**Completed:** Full OpenAPI→ReScript type generator with schema parsing, type conversion, enum handling, tests, and style guides

**Worked Well:**

- Incremental development approach (parser → converter → generator → tests)
- Comprehensive testing throughout development (9/9 tests passing)
- Clear separation of concerns across modules (SchemaParser, TypeGenerator, OpenApiGenerator)
- Effective error handling with Result types and descriptive messages

**Could Improve:**

- Faster discovery of correct API signatures (spent 60% of time on type system exploration)
- Better understanding of JSONSchema7 vs JSONSchema relationship upfront
- More efficient debugging of deprecated function usage (Option.getExn → Option.getOrThrow)

**ReScript Tooling Gaps:**

- **Type system discovery**: Manual exploration of node_modules to understand third-party APIs
- **Function signature guessing**: Trial-and-error for basic operations (Array.getLast doesn't exist)
- **Dependency relationship mapping**: Complex types like JSONSchema7.definition vs JSONSchema7.t required source reading
- **Late error discovery**: Deprecated functions and wrong module references only caught at compile time
- **Missing LSP dependency exploration**: No way to easily browse available functions/types in packages

**Result:** Working OpenAPI generator that converts schemas to idiomatic ReScript types, with comprehensive documentation and style guides.
