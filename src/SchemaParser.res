// Schema parser for extracting schemas from OpenAPI documents

// Type for a parsed schema with its name
type namedSchema = {
  name: string,
  schema: JSONSchema7.t,
}

// Parse OpenAPI document and extract all schemas from components/schemas
let parseDocument = (openApiDoc: Js.Json.t): result<array<namedSchema>, string> => {
  try {
    // Parse the JSON into OpenAPI types
    let parsedDoc = openApiDoc->Js.Json.decodeObject

    switch parsedDoc {
    | None => Error("Invalid OpenAPI document: not an object")
    | Some(doc) =>
      // Extract components.schemas
      switch doc->Js.Dict.get("components") {
      | None => Ok([]) // No components defined
      | Some(componentsJson) =>
        let components = componentsJson->Js.Json.decodeObject
        switch components {
        | None => Error("Invalid components section")
        | Some(componentsObj) =>
          switch componentsObj->Js.Dict.get("schemas") {
          | None => Ok([]) // No schemas defined
          | Some(schemasJson) =>
            let schemas = schemasJson->Js.Json.decodeObject
            switch schemas {
            | None => Error("Invalid schemas section")
            | Some(schemasObj) =>
              // Convert dictionary to array of named schemas
              let namedSchemas =
                schemasObj
                ->Js.Dict.entries
                ->Array.map(((name, schemaJson)) => {
                  // TODO: Proper JSON Schema parsing/validation here
                  // For now, we'll assume the JSON is a valid JSONSchema.t
                  let schema = schemaJson->Obj.magic
                  {name, schema}
                })
              Ok(namedSchemas)
            }
          }
        }
      }
    }
  } catch {
  | _ => Error("JSON parsing failed")
  }
}

// Load OpenAPI document from JSON file content
let parseFromJsonString = (jsonString: string): result<array<namedSchema>, string> => {
  try {
    let json = jsonString->Js.Json.parseExn
    parseDocument(json)
  } catch {
  | _ => Error("Invalid JSON")
  }
}

// Extract schemas that are objects (not primitives or arrays)
let filterObjectSchemas = (schemas: array<namedSchema>): array<namedSchema> => {
  schemas->Array.filter(({schema}) => {
    // Check if the schema has type "object" or has properties
    switch schema.type_ {
    | Some(typeArray) =>
      switch typeArray->JSONSchema7.Arrayable.classify {
      | Single(#object) => true
      | Array(types) => types->Array.includes(#object)
      | _ => false
      }
    | None =>
      // If no type is specified, check if it has properties (likely an object)
      schema.properties->Option.isSome
    }
  })
}

// Get schemas that define enums
let filterEnumSchemas = (schemas: array<namedSchema>): array<namedSchema> => {
  schemas->Array.filter(({schema}) => {
    schema.enum->Option.isSome
  })
}

// Extract all references ($ref) from a schema
let extractReferences = (schema: JSONSchema7.t): array<string> => {
  let refs = []

  // Check direct $ref
  switch schema.ref {
  | Some(ref) => refs->Array.push(ref)
  | None => ()
  }

  // Check properties for nested refs
  switch schema.properties {
  | Some(_properties) => // TODO: Recursively extract refs from nested schemas
    // This would require proper JSONSchema definition parsing
    ()
  | None => ()
  }

  refs
}
