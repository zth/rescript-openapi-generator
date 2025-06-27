# Generated Code Style Guide

_Style conventions for ReScript code generated from OpenAPI specifications_

## Type Naming

- **camelCase** for type names (ReScript requirement)
- **Convert from OpenAPI** schema names to camelCase
- **camelCase** for field names (convert from snake_case if needed)

```rescript
// ✅ Good - camelCase type names
type pet = { ... }
type apiResponse = { ... }
type userPreferences = { ... }

// ✅ Good - field naming
type user = {
  firstName: string,    // from "first_name"
  lastName: string,     // from "last_name"
  emailAddress: string, // from "email_address"
}
```

## Optional Fields

- **Use `?` syntax** for optional fields (non-required in OpenAPI)
- **No option wrapper** when using `?` syntax
- **Required fields first**, then optional fields

```rescript
// ✅ Good
type pet = {
  // Required fields first
  name: string,
  photoUrls: array<string>,
  // Optional fields after
  id?: int,
  category?: category,
  status?: petStatus,
}

// ❌ Avoid explicit option wrapper with ?
type pet = {
  id?: option<int>,  // redundant option wrapper
}
```

## Enum Types

- **Regular variants** for enums (not polyvariants)
- **Use `@as()` decorator** when variant names clash with ReScript naming rules
- **Unboxed variants** when single string payload

```rescript
// ✅ Good - regular variants
type petStatus = Available | Pending | Sold
type orderStatus = Placed | Approved | Delivered

// ✅ Good - use @as when names need runtime values
type status =
  | @as("in-progress") InProgress
  | @as("not-started") NotStarted
  | @as("done") Done

// ✅ Good - unboxed for single payload
type @unboxed customId = CustomId(string)

// ❌ Avoid polyvariants
type petStatus = [#available | #pending | #sold]
```

## Array Types

- **Generic array syntax** `array<t>` (lowercase type parameters)
- **Nested arrays** with proper type parameters
- **Reference types** in arrays

```rescript
// ✅ Good - lowercase type parameters
type pet = {
  photoUrls: array<string>,
  tags: array<tag>,
  categories: array<category>,
  metadata: array<array<string>>, // nested arrays
}

// ❌ Avoid uppercase type parameters
type pet = {
  tags: array<Tag>,  // should be array<tag>
}
```

## Reference Types

- **Direct type references** without module qualification
- **Assume all types in same module** unless explicitly namespaced
- **Use original schema names** for references

```rescript
// ✅ Good - direct references
type pet = {
  category: category,        // references Category schema
  tags: array<tag>,         // references Tag schema
}

// ❌ Avoid module qualification unless necessary
type pet = {
  category: Schemas.category,
}
```

## Field Ordering

- **Required fields first** in declaration order from OpenAPI
- **Optional fields second** in alphabetical order
- **Consistent indentation** (2 spaces)

```rescript
// ✅ Good
type pet = {
  // Required (in OpenAPI order)
  name: string,
  photoUrls: array<string>,
  // Optional (alphabetical)
  category?: category,
  id?: int,
  status?: petStatus,
  tags?: array<tag>,
}
```

## Type Formatting

- **One field per line** for readability
- **Trailing commas** on all fields
- **Consistent spacing** around types

```rescript
// ✅ Good
type category = {
  id?: int,
  name?: string,
}

type pet = {
  id?: int,
  name: string,
  category?: category,
  photoUrls: array<string>,
  tags?: array<tag>,
  status?: petStatus,
}
```

## File Organization

- **Generated header comment** indicating auto-generation
- **Enum types first** (dependencies)
- **Simple types next** (no references)
- **Complex types last** (with references)

```rescript
// ✅ Good file structure
// Generated ReScript types from OpenAPI specification

// Enums first
type petStatus = Available | Pending | Sold
type orderStatus = Placed | Approved | Delivered

// Simple types
type category = {
  id?: int,
  name?: string,
}

type tag = {
  id?: int,
  name?: string,
}

// Complex types with references
type pet = {
  name: string,
  photoUrls: array<string>,
  category?: category,
  tags?: array<tag>,
  status?: petStatus,
}
```

## Comments

- **Always emit schema descriptions** as comments when available
- **File header** indicating generator source
- **Type-level comments** for schema descriptions
- **Field-level comments** for property descriptions

```rescript
// ✅ Good - emit OpenAPI descriptions
// Generated ReScript types from OpenAPI specification

// A pet in the pet store
type pet = {
  id?: int, // Unique identifier for the pet
  name: string, // The name given to a pet
  status?: petStatus, // Pet status in the store
}

// Pet status in the store
type petStatus =
  | @as("available") Available // Pet is available for purchase
  | @as("pending") Pending     // Pet is pending sale
  | @as("sold") Sold          // Pet has been sold

// ❌ Don't skip descriptions when they exist in schema
type pet = {
  id?: int,
  name: string,
  status?: petStatus,
}
```
