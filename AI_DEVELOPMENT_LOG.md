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

---

## Session 2b: Style Guide Compliance & Code Generation Refinement (2025-06-27)

**Completed:** Fixed style guide compliance issues - camelCase type names, @as decorators, inline enum extraction

**Worked Well:**

- Systematic identification of style guide violations through demo testing
- Incremental fixes with build/test verification at each step
- Clear separation between generator logic and style requirements
- Effective use of Result types for error propagation during enum extraction

**Could Improve:**

- Initial implementation should have considered style guide requirements upfront
- Better validation of generated output against style requirements during development
- More comprehensive test cases covering edge cases (inline enums, type naming conventions)

**ReScript Tooling Gaps:**

- **No automatic style guide enforcement**: Had to manually verify camelCase vs PascalCase compliance
- **Limited code generation patterns**: No built-in utilities for common naming convention transformations
- **Style guide validation**: No linting rules or compile-time checks for generated code patterns
- **Type name validation**: ReScript allows both camelCase and PascalCase, making it easy to violate project conventions

**Key Technical Insights:**

- Inline enum extraction requires careful state management (global ref for extracted enums)
- Type ordering matters for dependencies (enums must be generated before referencing types)
- @as decorators are essential for proper runtime value modeling in generated code
- camelCase type names are a ReScript requirement, not just a style preference

**Result:** Fully compliant OpenAPI generator producing idiomatic ReScript code with proper runtime modeling.

---

## Session 3: Type Generation Pipeline & Compilation Testing (2025-06-27)

**Completed:** End-to-end pipeline for generating Petstore types into test project and verifying compilation success

**Worked Well:**

- Systematic debugging approach for compilation errors
- Quick iteration cycle: generate → compile → fix → repeat
- Clear ReScript compiler error messages helped identify syntax issues
- Fallback to JavaScript when ReScript external bindings proved problematic
- Comprehensive test file demonstrating all generated types work correctly

**Could Improve:**

- Initial understanding of ReScript variant syntax requirements (| prefixes)
- Better knowledge of external binding limitations upfront
- Reserved word handling should have been designed into the generator from the start
- More thorough testing of generated code patterns during development

**ReScript Tooling Gaps:**

- **External binding complexity**: Node.js module bindings are difficult to get right, often requiring JavaScript fallback
- **Variant syntax documentation**: No clear guidance that each variant constructor needs | prefix in generated code
- **Reserved word handling**: No built-in utilities or clear patterns for handling language reserved words in code generation
- **Generated code validation**: No tools to validate that generated ReScript code follows proper syntax patterns
- **Code generation debugging**: Hard to trace from generated JS back to ReScript generation logic

**Key Technical Discoveries:**

- ReScript variant definitions must use `| Constructor` format, not `Constructor |`
- Reserved words like `type` require `@as("type") type_` pattern with underscore suffix
- External bindings for file operations are fragile; pure JavaScript more reliable for build scripts
- Optional fields in generated types work better with `?` syntax than explicit `option<>` types

**Result:** Complete working pipeline that generates compilable Petstore types with proper reserved word handling and syntax compliance.

**Demo Output:**

```
✅ Generated Petstore types work correctly!
Pet: Buddy
Full pet status: Pet is available for adoption
Order status: Order has been approved
API response type: application/json
```
