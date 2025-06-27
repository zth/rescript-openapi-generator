# OpenAPI Generator Implementation Plan

## Overview

This document outlines the implementation plan for the ReScript OpenAPI Generator. The generator will produce fully-typed ReScript clients from OpenAPI 3.x specifications, leveraging `rescript-openapi`, `rescript-schema`, and `rescript-rest`.

## Phase 1: Schema Type Generation (CURRENT)

### Goal

Generate ReScript record types and polymorphic variants from OpenAPI `components/schemas`.

### Key Components

#### 1. Schema Parser (`src/SchemaParser.res`)

- Parse OpenAPI document using `rescript-openapi` types
- Extract schemas from `components/schemas` section
- Handle `$ref` resolution within schemas
- Support for JSONSchema7 format

#### 2. Type Generator (`src/TypeGenerator.res`)

- Convert JSONSchema to ReScript type definitions
- Generate record types for objects
- Generate polymorphic variants for enums
- Handle optional vs required fields
- Support array types and nested objects

#### 3. Reference Resolver (`src/ReferenceResolver.res`)

- Resolve `$ref` references between schemas
- Handle circular dependencies
- Build dependency graph for type ordering

#### 4. Code Formatter (`src/CodeFormatter.res`)

- Generate clean, readable ReScript code
- Handle naming conventions (camelCase to snake_case)
- Add appropriate type annotations and comments

### Target Output

For the petstore example, generate:

```rescript
// Generated types
type petStatus = [#available | #pending | #sold]

type category = {
  id?: int,
  name?: string,
}

type tag = {
  id?: int,
  name?: string,
}

type pet = {
  id?: int,
  name: string,        // required
  category?: category,
  photoUrls: array<string>,  // required
  tags?: array<tag>,
  status?: petStatus,
}

type order = {
  id?: int,
  petId?: int,
  quantity?: int,
  shipDate?: string,  // date-time format
  status?: [#placed | #approved | #delivered],
  complete?: bool,
}

// ... etc
```

### Implementation Steps

1. **✅ Setup project structure**
2. **🚧 Create basic schema parser** - Parse OpenAPI document
3. **🚧 Implement type mapping** - JSONSchema → ReScript types
4. **⏳ Handle references** - Resolve $ref between schemas
5. **⏳ Generate enums** - Convert enum to polymorphic variants
6. **⏳ Add tests** - Test with petstore schemas
7. **⏳ Code generation** - Output formatted ReScript code

### Technical Decisions

- **Type mapping strategy**:

  - `object` → `record`
  - `enum` → `polymorphic variant`
  - `array` → `array<T>`
  - `string`/`number`/`boolean` → native types
  - `integer` → `int`
  - `number` → `float`

- **Optional fields**: Use `field?: type` syntax for non-required properties

- **Naming**: Convert OpenAPI names to ReScript conventions (camelCase)

## Phase 2: Schema Validation Generation (NEXT)

### Goal

Generate `rescript-schema` encoders/decoders for runtime validation.

### Components

- Schema Codec Generator
- Validation helpers
- Error handling types

### Target Output

```rescript
// Generated schemas
module PetSchema = {
  let schema = S.object(s => {
    id: s.field("id", S.option(S.int)),
    name: s.field("name", S.string),
    category: s.field("category", S.option(CategorySchema.schema)),
    photoUrls: s.field("photoUrls", S.array(S.string)),
    tags: s.field("tags", S.option(S.array(TagSchema.schema))),
    status: s.field("status", S.option(petStatusSchema)),
  })
}
```

## Phase 3: Endpoint Generation

### Goal

Generate `rescript-rest` endpoint definitions from OpenAPI paths.

### Components

- Path Parser
- Operation Generator
- Parameter handling
- Response types

## Phase 4: Client Generation

### Goal

Complete, ready-to-use client with HTTP calls.

### Components

- Client module generation
- HTTP adapter integration
- Authentication handling
- Error types

## Phase 5: CLI Tool

### Goal

Standalone CLI for generating clients from OpenAPI files.

### Components

- Command-line interface
- File I/O operations
- Configuration options

---

## Testing Strategy

- Unit tests for each component
- Integration tests with petstore API
- Generated code compilation tests
- Example applications

## Success Criteria

- ✅ Generates compilable ReScript code
- ✅ 100% type coverage for schemas
- ✅ Handles complex nested references
- ✅ Produces idiomatic ReScript code
- ✅ Comprehensive test coverage
