# Generator Code Style Guide

_Style conventions for the OpenAPI generator implementation_

## Pipe-First Style

- **Use pipe-first** for data transformations
- **Chain operations** naturally with `->`
- **Intermediate variables** for complex operations

```rescript
// ✅ Good
let namedSchemas = schemasObj
  ->Js.Dict.entries
  ->Array.map(((name, schemaJson)) => {
    let schema = schemaJson->parseSchema
    {name, schema}
  })

// ❌ Avoid imperative style when functional is clearer
```

## Result Types

- **Use Result types** when operations can fail
- **Descriptive error messages** with context
- **Error aggregation** when processing multiple items

```rescript
// ✅ Good
let convertProperty = (name, schema): result<field, string> => {
  switch validateSchema(schema) {
  | Error(msg) => Error(`Property ${name}: ${msg}`)
  | Ok(valid) => processProperty(valid)
  }
}

// ❌ Avoid exceptions when result types are more appropriate
let convertProperty = (name, schema) => {
  if isInvalid(schema) {
    raise(InvalidSchema("bad schema"))
  }
  processProperty(schema)
}
```

## Prefer Variants Over Polyvariants

- **Use regular variants** for closed sets of values
- **Unboxed variants** when appropriate for performance
- **Polyvariants only** when you need open/extensible types

```rescript
// ✅ Good - regular variants for known types
type rescriptType =
  | String | Int | Float | Bool
  | Array(rescriptType)
  | Reference(string)

// ✅ Good - unboxed when single payload
type @unboxed operationResult = Success(string) | Error(string)

// ❌ Avoid polyvariants for closed sets
type rescriptType = [#string | #int | #float | #bool | #array | #reference]
```

## Comments

- **TODO comments** for known limitations
- **Type conversion explanations** for complex mappings
- **External dependency notes** when using specific APIs

```rescript
// ✅ Good
// Extract type name from reference like "#/components/schemas/Pet" -> "Pet"
let typeName = parts->Array.get(parts->Array.length - 1)

// TODO: Recursively extract refs from nested schemas
// This would require proper JSONSchema definition parsing
```
