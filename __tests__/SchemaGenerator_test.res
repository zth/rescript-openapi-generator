open Ava

// Test the schema generator with the petstore OpenAPI spec
asyncTest("should generate complete petstore module", async t => {
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

  let expectedModule = `// Generated ReScript types from OpenAPI specification

type category = {
  id?: int,
  name?: string,
}

type petStatus = @as("available") Available | @as("pending") Pending | @as("sold") Sold

type pet = {
  name: string,
  photoUrls: array<string>,
  category?: category,
  id?: int,
  status?: petStatus,
}`

  switch OpenApiGenerator.generateModule(testOpenApiJson) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(moduleCode) =>
    // Compare the entire generated module
    t->Assert.is(moduleCode, expectedModule)
  }
})

test("should generate complete simple object module", t => {
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

  let expectedModule = `// Generated ReScript types from OpenAPI specification

type simpleObject = {
  name: string,
  age?: int,
}`

  switch OpenApiGenerator.generateModule(simpleSchema) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(moduleCode) =>
    t->Assert.is(moduleCode, expectedModule)
  }
})

test("should generate complete enum module", t => {
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

  let expectedModule = `// Generated ReScript types from OpenAPI specification

type status = @as("active") Active | @as("inactive") Inactive | @as("pending") Pending`

  switch OpenApiGenerator.generateModule(enumSchema) {
  | Error(msg) => t->Assert.fail(`Generation failed: ${msg}`)
  | Ok(moduleCode) =>
    t->Assert.is(moduleCode, expectedModule)
  }
})

test("should handle empty components", t => {
  let emptySchema = `{
    "openapi": "3.0.4",
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {}
  }`

  let expectedModule = `// Generated ReScript types from OpenAPI specification

`

  switch OpenApiGenerator.generateModule(emptySchema) {
  | Error(_) => t->Assert.fail("Should handle empty components")
  | Ok(moduleCode) => t->Assert.is(moduleCode, expectedModule)
  }
})

test("should generate complex module with inline enums", t => {
  let complexSchema = `{
    "openapi": "3.0.4",
    "info": {"title": "Test", "version": "1.0.0"},
    "components": {
      "schemas": {
        "User": {
          "type": "object", 
          "properties": {
            "id": {"type": "integer"},
            "name": {"type": "string"},
            "role": {
              "type": "string",
              "enum": ["admin", "user", "guest"]
            },
            "preferences": {
              "type": "object",
              "properties": {
                "theme": {
                  "type": "string",
                  "enum": ["light", "dark"]
                },
                "notifications": {"type": "boolean"}
              }
            }
          },
          "required": ["id", "name"]
        }
      }
    }
  }`

  let expectedModule = `// Generated ReScript types from OpenAPI specification

type userRole = @as("admin") Admin | @as("user") User | @as("guest") Guest

type user = {
  id: int,
  name: string,
  preferences?: unknown,
  role?: userRole,
}`

  switch OpenApiGenerator.generateModule(complexSchema) {
  | Error(msg) => t->Assert.fail(`Module generation failed: ${msg}`)
  | Ok(moduleCode) =>
    t->Assert.is(moduleCode, expectedModule)
  }
})
