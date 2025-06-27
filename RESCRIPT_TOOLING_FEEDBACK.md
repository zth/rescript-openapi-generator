# ReScript Development Pain Points & Tooling Opportunities

_Based on implementing an OpenAPI generator in ReScript_

## Core Development Pain

The primary friction in this ReScript development session was **type system discovery** - ReScript's excellent type safety became a debugging exercise when working with third-party dependencies. Most compilation errors required iterative guessing rather than guided exploration.

### Specific Pain Points

1. **Dependency API Discovery**: Had to manually explore `node_modules` to understand what types and functions were available in packages like `rescript-openapi` and `rescript-json-schema`.

2. **Function Signature Guessing**: Spent multiple iterations discovering correct function names and signatures (e.g., `Array.getLast` doesn't exist, need `Array.get(arr, -1)`).

3. **Type Relationship Understanding**: Complex types like `JSONSchema7.definition` vs `JSONSchema7.t` required reading source code to understand the relationship and proper usage patterns.

4. **Late Error Discovery**: Issues like deprecated functions (`Option.getExn` → `Option.getOrThrow`) and wrong module references (`JSONSchema.Arrayable` → `JSONSchema7.Arrayable`) only surfaced during compilation.

## Code Generation Specific Pain Points

Based on implementing the complete type generation pipeline, several additional pain points emerged:

### 5. **External Binding Complexity**

ReScript's external bindings for Node.js operations are fragile and hard to debug:

```rescript
// This compiled but failed at runtime with cryptic errors:
module Fs = {
  @bs.module("fs") external readFileSync: (string, string) => string = "readFileSync"
  @bs.module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
}

// Had to fall back to JavaScript:
// scripts/generatePetstoreTypes.mjs
import { readFileSync, writeFileSync } from 'fs';
```

### 6. **Variant Syntax Documentation Gap**

The correct syntax for generated variants was unclear and required trial-and-error:

```rescript
// Generated this (compilation error):
type status = @as("active") Active | @as("inactive") Inactive

// Had to discover this is required:
type status = | @as("active") Active | @as("inactive") Inactive
```

### 7. **Reserved Word Handling**

No guidance or utilities for handling language reserved words in generated code:

```rescript
// OpenAPI schema has "type" field - this fails:
type apiResponse = {
  type: string,  // "type" is reserved!
}

// Had to manually implement:
type apiResponse = {
  @as("type") type_: string,
}
```

## Session Examples

### Example 1: The Array.getLast Hunt

```rescript
// What I tried first (compilation error):
let typeName = ref->String.split("/")->Array.getLast->Option.getOr("Unknown")

// Had to discover through trial that this doesn't exist, then find:
let parts = ref->String.split("/")
let typeName = parts->Array.get(parts->Array.length - 1)->Option.getOr("Unknown")
```

### Example 2: Module Reference Mystery

```rescript
// First attempt (compilation error):
switch typeArrayable->JSONSchema.Arrayable.classify {

// After exploring node_modules, discovered:
switch typeArrayable->JSONSchema7.Arrayable.classify {
```

### Example 3: The External Binding Debugging Maze

```rescript
// ReScript external binding (compiled but failed at runtime):
@val external __dirname: string = "__dirname"
let path = Path.resolve(__dirname, "../examples/petstore/openapi.json")
let content = Fs.readFileSync(path, "utf8")  // ReferenceError: readFileSync is not defined

// JavaScript equivalent (worked immediately):
const path = resolve(__dirname, "../examples/petstore/openapi.json");
const content = readFileSync(path, "utf8");
```

### Example 4: Variant Syntax Trial and Error

```rescript
// Generated this initially (syntax error):
type orderStatus = @as("placed") Placed | @as("approved") Approved | @as("delivered") Delivered

// Compiler said: "Did you mean `placed` instead of `Placed`?"
// Tried lowercasing variants (wrong direction)

// Finally discovered the | prefix requirement:
type orderStatus = | @as("placed") Placed | @as("approved") Approved | @as("delivered") Delivered
```

## Concrete Tooling Suggestions

### 1. Enhanced LSP with Dependency Exploration

```bash
# In VSCode, when typing "JSONSchema7." show:
# - All available modules/types with signatures
# - Usage examples from common patterns
# - Quick navigation to source definitions
```

### 2. ReScript Package Explorer CLI

```bash
$ rescript-explore rescript-json-schema
Available modules:
  - JSONSchema7.t (main schema type)
  - JSONSchema7.definition (schema | boolean)
  - JSONSchema7.Definition.classify : definition -> tagged

$ rescript-explore --usage JSONSchema7.Definition.classify
Common patterns:
  switch def->JSONSchema7.Definition.classify {
  | Schema(schema) => (* work with schema *)
  | Boolean(bool) => (* handle boolean schema *)
  }
```

### 3. Compilation Error Enhancement

```bash
# Instead of:
Error: The value getLast can't be found in Array

# Provide:
Error: Array.getLast doesn't exist
Suggestion: Use Array.get(arr, index) or Array.at(arr, -1) for last element
Auto-fix available: Replace with Array.get(arr, Array.length(arr) - 1)
```

### 4. External Binding Validator

```bash
# Validate external bindings generate correct JavaScript:
$ rescript check-externals src/MyModule.res
Warning: External binding @bs.module("fs") may not work in ESM context
Suggestion: Use import statements in separate .mjs file
Auto-fix: Generate wrapper JavaScript file with proper imports
```

### 5. Code Generation Utilities

```bash
# Built-in reserved word handling:
$ rescript format --fix-reserved-words src/Generated.res
Auto-fixed: type → @as("type") type_, class → @as("class") class_

# Variant syntax validator:
$ rescript lint --check-variants src/
Error: Variant constructors missing | prefix
Auto-fix available: Add | prefix to all variant constructors
```

### 6. OpenAPI-Specific Generator

```bash
$ rescript-openapi generate petstore.json --output src/Types.res
# Generates complete, compilable ReScript types with proper relationships
# Eliminates the need to manually implement schema → type conversion
```

### 7. Style Guide Enforcement & Code Generation

```bash
# Automatic style validation during compilation:
$ rescript build --style-guide generated-code
Warning: Type name 'PetStatus' should be camelCase ('petStatus')
Error: Enum variant 'Available' missing @as decorator for runtime value

# Code generation utilities:
$ rescript format --fix-naming-conventions src/
Auto-fixed: PetStatus → petStatus, UserProfile → userProfile
```

## Additional Pain Points (Style Guide & Code Generation)

### Code Generation Pattern Discovery

When building a code generator, ReScript lacks built-in utilities for common patterns:

- **Naming convention transformations** (PascalCase ↔ camelCase ↔ snake_case)
- **Style guide validation** for generated code
- **Type dependency ordering** (no automatic topological sort for generated types)
- **Runtime value modeling** (when to use @as decorators vs plain variants)
- **Reserved word escaping** (no standard patterns or utilities)

### Style Guide Enforcement

ReScript's flexibility in type naming creates consistency challenges:

- Both `type User = {...}` and `type user = {...}` compile successfully
- No compile-time enforcement of project naming conventions
- Style violations only discovered through manual testing or external linting

### External Binding Reliability

ReScript external bindings work well for simple cases but become unreliable for complex Node.js operations:

- **Runtime binding failures** are hard to debug (missing imports, wrong module format)
- **Module system mismatches** between ReScript expectations and actual Node.js modules
- **Fallback to JavaScript** often more reliable than debugging binding issues

The core insight: ReScript's type system is powerful but tooling for _discovering_ and _exploring_ that type information during development is the primary bottleneck. Additionally, code generation scenarios expose gaps in style enforcement, pattern utilities, and external binding reliability.
