// Main OpenAPI generator module

type generatedType = {
  name: string,
  definition: string,
}

// Generate ReScript types from OpenAPI JSON string
let generateTypes = (openApiJsonString: string): result<array<generatedType>, string> => {
  // Parse the OpenAPI document
  SchemaParser.parseFromJsonString(openApiJsonString)->Result.flatMap(schemas => {
    // Clear any previous extracted enums
    TypeGenerator.clearExtractedEnums()

    // Convert each schema to ReScript types
    let typeResults = schemas->Array.map(namedSchema => {
      TypeGenerator.convertSchema(namedSchema)->Result.map(
        rescriptType => {
          let definition = TypeGenerator.generateTypeDefinition(namedSchema.name, rescriptType)
          {name: namedSchema.name, definition}
        },
      )
    })

    // Check for any conversion errors
    let errors = typeResults->Array.filterMap(result => {
      switch result {
      | Error(msg) => Some(msg)
      | Ok(_) => None
      }
    })

    if errors->Array.length > 0 {
      Error(`Type generation failed: ${errors->Array.join(", ")}`)
    } else {
      let generatedTypes = typeResults->Array.filterMap(result => {
        switch result {
        | Ok(generatedType) => Some(generatedType)
        | Error(_) => None
        }
      })

      // Generate extracted enum types first (according to style guide)
      let extractedEnumDefinitions = TypeGenerator.generateExtractedEnumDefinitions()
      let enumTypes = extractedEnumDefinitions->Array.map(definition => {
        // Extract type name from definition like "type petStatus = ..."
        let typeName = definition->String.split(" ")->Array.get(1)->Option.getOr("Unknown")
        {name: typeName, definition}
      })

      // Return enums first, then regular types (following style guide ordering)
      Ok(Array.concat(enumTypes, generatedTypes))
    }
  })
}

// Generate a complete ReScript module string
let generateModule = (openApiJsonString: string): result<string, string> => {
  generateTypes(openApiJsonString)->Result.map(types => {
    let header = "// Generated ReScript types from OpenAPI specification\n\n"
    let typeDefinitions =
      types
      ->Array.map(({definition}) => definition)
      ->Array.join("\n\n")

    header ++ typeDefinitions
  })
}

// Helper function to generate types from a file path (for future CLI usage)
// For now, this is just a placeholder since we don't have file I/O yet
let generateFromFile = (_filePath: string): result<string, string> => {
  Error("File I/O not implemented yet - use generateModule with JSON string")
}
