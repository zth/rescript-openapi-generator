open Ava

// Test the schema generator with the petstore OpenAPI spec
asyncTest("should parse petstore schemas", async t => {
  // Read the petstore OpenAPI JSON
  // Note: In a real implementation, we'd read from file
  // For now, we'll use a minimal test schema
  let testOpenApiJson = `{
    "openapi": "3.0.4",
    "info": {
      "title": "Test API",
      "version": "1.0.0"
    },
    "components": {
      "schemas": {
        "Category": {
          "type": "object",
          "properties": {
            "id": {
              "type": "integer",
              "format": "int64"
            },
            "name": {
              "type": "string"
            }
          }
        },
        "PetStatus": {
          "type": "string",
          "enum": ["available", "pending", "sold"]
        },
        "Pet": {
          "type": "object",
          "required": ["name", "photoUrls"],
          "properties": {
            "id": {
              "type": "integer",
              "format": "int64"
            },
            "name": {
              "type": "string"
            },
            "category": {
              "$ref": "#/components/schemas/Category"
            },
            "photoUrls": {
              "type": "array",
              "items": {
                "type": "string"
              }
            },
            "status": {
              "$ref": "#/components/schemas/PetStatus"
            }
          }
        }
      }
    }
  }`

  switch OpenApiGenerator.generateTypes(testOpenApiJson) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(types) =>
    // Should generate types for Category, PetStatus, and Pet
    t->Assert.is(types->Array.length, 3)

    // Check that we have the expected type names
    let typeNames = types->Array.map(({name}) => name)
    t->Assert.is(typeNames->Array.includes("Category"), true)
    t->Assert.is(typeNames->Array.includes("PetStatus"), true)
    t->Assert.is(typeNames->Array.includes("Pet"), true)
  }
})

test("should parse simple object schema", t => {
  let simpleSchema = `{
    "openapi": "3.0.4",
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {
      "schemas": {
        "SimpleObject": {
          "type": "object",
          "properties": {
            "name": {"type": "string"},
            "age": {"type": "integer"}
          },
          "required": ["name"]
        }
      }
    }
  }`

  switch OpenApiGenerator.generateTypes(simpleSchema) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(types) =>
    t->Assert.is(types->Array.length, 1)
    let generatedType = types->Array.get(0)->Option.getOrThrow
    t->Assert.is(generatedType.name, "SimpleObject")

    // The generated definition should contain the fields
    t->Assert.is(generatedType.definition->String.includes("name:"), true)
    t->Assert.is(generatedType.definition->String.includes("age?:"), true)
  }
})

test("should parse enum schema", t => {
  let enumSchema = `{
    "openapi": "3.0.4", 
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {
      "schemas": {
        "Status": {
          "type": "string",
          "enum": ["active", "inactive", "pending"]
        }
      }
    }
  }`

  switch OpenApiGenerator.generateTypes(enumSchema) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(types) =>
    t->Assert.is(types->Array.length, 1)
    let generatedType = types->Array.get(0)->Option.getOrThrow
    t->Assert.is(generatedType.name, "Status")

    // Should generate a regular variant
    t->Assert.is(generatedType.definition->String.includes("Active"), true)
    t->Assert.is(generatedType.definition->String.includes("Inactive"), true)
    t->Assert.is(generatedType.definition->String.includes("Pending"), true)
  }
})

test("should handle empty components", t => {
  let emptySchema = `{
    "openapi": "3.0.4",
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {}
  }`

  switch OpenApiGenerator.generateTypes(emptySchema) {
  | Error(_) => t->Assert.fail("Should handle empty components")
  | Ok(types) => t->Assert.is(types->Array.length, 0)
  }
})

test("should generate complete module", t => {
  let simpleSchema = `{
    "openapi": "3.0.4",
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {
      "schemas": {
        "User": {
          "type": "object", 
          "properties": {
            "id": {"type": "integer"},
            "name": {"type": "string"}
          },
          "required": ["id"]
        }
      }
    }
  }`

  switch OpenApiGenerator.generateModule(simpleSchema) {
  | Error(msg) => t->Assert.fail(`Module generation failed: ${msg}`)
  | Ok(moduleCode) =>
    // Should include header comment
    t->Assert.is(moduleCode->String.includes("Generated ReScript types"), true)

    // Should include type definition
    t->Assert.is(moduleCode->String.includes("type user"), true)
    t->Assert.is(moduleCode->String.includes("id:"), true)
    t->Assert.is(moduleCode->String.includes("name?:"), true)
  }
})
