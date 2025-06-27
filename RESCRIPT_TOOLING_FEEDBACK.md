# ReScript Development Pain Points & Tooling Opportunities

_Based on implementing an OpenAPI generator in ReScript_

## Core Development Pain

The primary friction in this ReScript development session was **type system discovery** - ReScript's excellent type safety became a debugging exercise when working with third-party dependencies. Most compilation errors required iterative guessing rather than guided exploration.

### Specific Pain Points

1. **Dependency API Discovery**: Had to manually explore `node_modules` to understand what types and functions were available in packages like `rescript-openapi` and `rescript-json-schema`.

2. **Function Signature Guessing**: Spent multiple iterations discovering correct function names and signatures (e.g., `Array.getLast` doesn't exist, need `Array.get(arr, -1)`).

3. **Type Relationship Understanding**: Complex types like `JSONSchema7.definition` vs `JSONSchema7.t` required reading source code to understand the relationship and proper usage patterns.

4. **Late Error Discovery**: Issues like deprecated functions (`Option.getExn` → `Option.getOrThrow`) and wrong module references (`JSONSchema.Arrayable` → `JSONSchema7.Arrayable`) only surfaced during compilation.

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

### 4. OpenAPI-Specific Generator

```bash
$ rescript-openapi generate petstore.json --output src/Types.res
# Generates complete, compilable ReScript types with proper relationships
# Eliminates the need to manually implement schema → type conversion
```

The core insight: ReScript's type system is powerful but tooling for _discovering_ and _exploring_ that type information during development is the primary bottleneck.
