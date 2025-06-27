// Demo of the OpenAPI generator

let demoSchema = `{
  "openapi": "3.0.4",
  "info": {
    "title": "Pet Store API",
    "version": "1.0.0"
  },
  "components": {
    "schemas": {
      "Pet": {
        "type": "object",
        "required": ["name", "photoUrls"],
        "properties": {
          "id": {
            "type": "integer",
            "format": "int64"
          },
          "name": {
            "type": "string",
            "example": "doggie"
          },
          "photoUrls": {
            "type": "array",
            "items": {
              "type": "string"
            }
          },
          "status": {
            "type": "string",
            "enum": ["available", "pending", "sold"]
          }
        }
      },
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
      }
    }
  }
}`

// Generate and log the types
let demo = () => {
  switch OpenApiGenerator.generateModule(demoSchema) {
  | Error(msg) => Console.log(`Error: ${msg}`)
  | Ok(generatedCode) => {
      Console.log("Generated ReScript types:")
      Console.log("=" ++ String.repeat("=", 50))
      Console.log(generatedCode)
      Console.log("=" ++ String.repeat("=", 50))
    }
  }
}

// Run the demo
demo()
