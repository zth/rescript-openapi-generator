// Type generator for converting JSONSchema to ReScript type definitions

// Generated ReScript type information
type rec rescriptType =
  | String
  | Int
  | Float
  | Bool
  | Array(rescriptType)
  | Option(rescriptType)
  | Record(array<recordField>)
  | Variant(array<string>)
  | Reference(string)
  | Unknown

and recordField = {
  name: string,
  type_: rescriptType,
  required: bool,
}

// Type for extracted enum information
type extractedEnum = {
  name: string,
  variants: array<string>,
}

// Global state for extracted enums (will be reset for each schema)
let extractedEnums: ref<array<extractedEnum>> = ref([])

// Convert type name to camelCase
let toCamelCase = (name: string): string => {
  name->String.get(0)->Option.getOr("")->String.toLowerCase ++ name->String.sliceToEnd(~start=1)
}

// Convert JSONSchema type to ReScript type
let mapPrimitiveType = (schemaType: JSONSchema7.typeName): rescriptType => {
  switch schemaType {
  | #string => String
  | #integer => Int
  | #number => Float
  | #boolean => Bool
  | #array => Unknown // Arrays need items type
  | #object => Unknown // Objects need properties
  | #null => Unknown // Not supported directly
  }
}

// Generate variant names from enum values
let generateVariantNames = (enumValues: array<Js.Json.t>): result<array<string>, string> => {
  try {
    let variants = enumValues->Array.map(value => {
      switch value->Js.Json.classify {
      | JSONString(str) => {
          // Convert enum string to proper ReScript variant name
          // e.g. "available" -> "Available", "in-progress" -> "InProgress"
          let capitalized =
            str
            ->String.split("-")
            ->Array.map(part => {
              let firstChar = part->String.get(0)->Option.getOr("")->String.toUpperCase
              let rest = part->String.sliceToEnd(~start=1)
              firstChar ++ rest
            })
            ->Array.join("")

          // Always use @as decorator to model runtime values correctly
          `@as("${str}") ${capitalized}`
        }
      | _ => "Unknown" // TODO: Handle non-string enums
      }
    })
    Ok(variants)
  } catch {
  | _ => Error("Failed to parse enum values")
  }
}

// Generate ReScript regular variant from enum values
let generateVariantFromEnum = (enumValues: array<Js.Json.t>): result<rescriptType, string> => {
  generateVariantNames(enumValues)->Result.map(variants => Variant(variants))
}

// Extract inline enum and return type name
let extractInlineEnum = (baseName: string, propName: string, enumValues: array<Js.Json.t>): result<
  string,
  string,
> => {
  generateVariantNames(enumValues)->Result.map(variants => {
    // Generate enum type name in camelCase like "petStatus" from "Pet" + "status"
    let baseNameLower =
      baseName->String.get(0)->Option.getOr("")->String.toLowerCase ++
        baseName->String.sliceToEnd(~start=1)
    let propNameCapitalized =
      propName->String.get(0)->Option.getOr("")->String.toUpperCase ++
        propName->String.sliceToEnd(~start=1)
    let enumTypeName = baseNameLower ++ propNameCapitalized

    // Store extracted enum for later generation
    let extractedEnum = {name: enumTypeName, variants}
    extractedEnums := Array.concat(extractedEnums.contents, [extractedEnum])

    // Return the type name to reference
    enumTypeName
  })
}

// Helper function to convert actual schema
let convertPropertySchema = (
  baseName: string,
  name: string,
  propSchema: JSONSchema7.t,
  isRequired: bool,
): result<recordField, string> => {
  // Handle $ref references
  switch propSchema.ref {
  | Some(ref) =>
    // Extract type name from reference like "#/components/schemas/Pet" -> "pet"
    let parts = ref->String.split("/")
    let typeName = parts->Array.get(parts->Array.length - 1)->Option.getOr("Unknown")
    let fieldType = Reference(toCamelCase(typeName))
    // Don't wrap in Option - we'll use ? syntax instead
    Ok({name, type_: fieldType, required: isRequired})
  | None =>
    // Check for enum first (regardless of type)
    switch propSchema.enum {
    | Some(enumValues) =>
      // Extract inline enum as separate type and reference it
      extractInlineEnum(baseName, name, enumValues)->Result.map(enumTypeName => {
        {name, type_: Reference(toCamelCase(enumTypeName)), required: isRequired}
      })
    | None =>
      // Handle direct types
      switch propSchema.type_ {
      | Some(typeArrayable) =>
        switch typeArrayable->JSONSchema7.Arrayable.classify {
        | Single(primitiveType) =>
          let baseType = mapPrimitiveType(primitiveType)
          let finalType = switch (primitiveType, baseType) {
          | (#array, _) =>
            // Handle array type - need to get items
            switch propSchema.items {
            | Some(itemsArrayable) =>
              switch itemsArrayable->JSONSchema7.Arrayable.classify {
              | Single(_itemSchema) =>
                // TODO: Recursively convert item schema
                // For now, assume string arrays
                Array(String)
              | Array(_) => Unknown // Complex array schemas not supported yet
              }
            | None => Array(Unknown)
            }
          | (_, rescriptType) => rescriptType
          }
          // Don't wrap in Option - we'll use ? syntax instead
          Ok({name, type_: finalType, required: isRequired})
        | Array(_) => Error("Union types not supported yet")
        }
      | None => Error(`Unsupported property schema for field: ${name}`)
      }
    }
  }
}

// Convert a single property schema to ReScript field
let convertProperty = (
  baseName: string,
  name: string,
  propDefinition: JSONSchema7.definition,
  isRequired: bool,
): result<recordField, string> => {
  // First classify the definition (it could be a schema or boolean)
  switch propDefinition->JSONSchema7.Definition.classify {
  | Boolean(_) => Error("Boolean schema definitions not supported")
  | Schema(propSchema) => convertPropertySchema(baseName, name, propSchema, isRequired)
  }
}

// Convert JSONSchema object to ReScript record type
let convertObjectSchema = (
  baseName: string,
  schema: JSONSchema7.t,
  requiredFields: array<string>,
): result<rescriptType, string> => {
  switch schema.properties {
  | None => Error("Object schema has no properties")
  | Some(properties) =>
    let propertyNames = properties->Js.Dict.keys

    // Convert each property
    let fieldResults = propertyNames->Array.map(propName => {
      let propSchema =
        properties->Js.Dict.get(propName)->Option.getOr(JSONSchema7.Definition.boolean(false))
      let isRequired = requiredFields->Array.includes(propName)
      convertProperty(baseName, propName, propSchema, isRequired)
    })

    // Check if all conversions succeeded
    let errors = fieldResults->Array.filterMap(result => {
      switch result {
      | Error(msg) => Some(msg)
      | Ok(_) => None
      }
    })

    if errors->Array.length > 0 {
      Error(`Property conversion failed: ${errors->Array.join(", ")}`)
    } else {
      let fields = fieldResults->Array.filterMap(result => {
        switch result {
        | Ok(field) => Some(field)
        | Error(_) => None
        }
      })
      Ok(Record(fields))
    }
  }
}

// Main conversion function
let convertSchema = (namedSchema: SchemaParser.namedSchema): result<rescriptType, string> => {
  let {schema} = namedSchema

  // Handle enums first
  switch schema.enum {
  | Some(enumValues) => generateVariantFromEnum(enumValues)
  | None =>
    // Handle objects
    switch schema.type_ {
    | Some(typeArrayable) =>
      switch typeArrayable->JSONSchema7.Arrayable.classify {
      | Single(#object) =>
        let requiredFields = schema.required->Option.getOr([])
        convertObjectSchema(namedSchema.name, schema, requiredFields)
      | Single(primitiveType) => Ok(mapPrimitiveType(primitiveType))
      | Array(_) => Error("Union types not supported")
      }
    | None =>
      // No explicit type - check if it has properties (assume object)
      switch schema.properties {
      | Some(_) =>
        let requiredFields = schema.required->Option.getOr([])
        convertObjectSchema(namedSchema.name, schema, requiredFields)
      | None => Error("Schema has no type or properties")
      }
    }
  }
}

// Generate extracted enum type definitions
let generateExtractedEnumDefinitions = (): array<string> => {
  extractedEnums.contents->Array.map(({name, variants}) => {
    let variantString = variants->Array.join(" | ")
    `type ${toCamelCase(name)} = ${variantString}`
  })
}

// Clear extracted enums (call this before processing new schemas)
let clearExtractedEnums = (): unit => {
  extractedEnums := []
}

// Generate ReScript type definition code
let generateTypeDefinition = (name: string, rescriptType: rescriptType): string => {
  let rec typeToString = (type_: rescriptType): string => {
    switch type_ {
    | String => "string"
    | Int => "int"
    | Float => "float"
    | Bool => "bool"
    | Array(itemType) => `array<${typeToString(itemType)}>`
    | Option(innerType) => `option<${typeToString(innerType)}>`
    | Reference(typeName) => typeName
    | Record(fields) =>
      // Sort fields: required first, then optional (alphabetically)
      let requiredFields = fields->Array.filter(field => field.required)
      let optionalFields = fields->Array.filter(field => !field.required)
      let sortedOptionalFields =
        optionalFields->Array.toSorted((a, b) => String.compare(a.name, b.name))
      let sortedFields = Array.concat(requiredFields, sortedOptionalFields)

      let fieldStrings = sortedFields->Array.map(field => {
        let optionalMarker = field.required ? "" : "?"
        let fieldType = field.required
          ? field.type_
          : {
              // If field is optional and type is wrapped in Option, unwrap it for the ? syntax
              switch field.type_ {
              | Option(innerType) => innerType
              | other => other
              }
            }
        `  ${field.name}${optionalMarker}: ${typeToString(fieldType)},`
      })
      "{\n" ++ fieldStrings->Array.join("\n") ++ "\n}"
    | Variant(variants) =>
      let variantStrings = variants->Array.map(v => v)
      variantStrings->Array.join(" | ")
    | Unknown => "unknown"
    }
  }

  `type ${toCamelCase(name)} = ${typeToString(rescriptType)}`
}
