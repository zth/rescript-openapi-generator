// Script to generate Petstore types into test-generated-types folder

// ESM imports for Node.js file operations and path utilities
@module("fs") external readFileSync: (string, string) => string = "readFileSync"
@module("fs") external writeFileSync: (string, string) => unit = "writeFileSync"
@module("fs") external existsSync: string => bool = "existsSync"
@module("fs") external mkdirSync: (string, {..}) => unit = "mkdirSync"
@module("path") external join: (string, string) => string = "join"
@module("path") external resolve: (string, string) => string = "resolve"
@module("path") external dirname: string => string = "dirname"
@module("url") external fileURLToPath: string => string = "fileURLToPath"

// Get current directory in ESM
let getCurrentDir = () => {
  let importMetaUrl = %raw("import.meta.url")
  fileURLToPath(importMetaUrl)->dirname
}

// Generate Petstore types and write to test project
let generatePetstoreTypes = () => {
  Console.log("🚀 Starting Petstore type generation...")
  
  try {
    // Read the Petstore OpenAPI schema
    let currentDir = getCurrentDir()
    let petstoreSchemaPath = resolve(currentDir, "../examples/petstore/openapi.json")
    Console.log(`📁 Reading Petstore schema from: ${petstoreSchemaPath}`)
    
    // Check if file exists
    if !existsSync(petstoreSchemaPath) {
      Console.error(`❌ Petstore schema file not found at: ${petstoreSchemaPath}`)
      %raw("process.exit(1)")
    }
    
    let openApiJsonString = readFileSync(petstoreSchemaPath, "utf8")
    Console.log(`✅ Read ${openApiJsonString->String.length->Int.toString} characters from schema file`)
    
    // Generate the ReScript module
    Console.log("🔄 Generating ReScript module...")
    switch OpenApiGenerator.generateModule(openApiJsonString) {
    | Error(msg) => {
        Console.error(`❌ Type generation failed: ${msg}`)
        %raw("process.exit(1)")
      }
    | Ok(moduleCode) => {
        Console.log("✅ Module generation successful!")
        
        // Write to test-generated-types/src/GeneratedPetstoreTypes.res
        let testProjectSrcPath = resolve(currentDir, "../test-generated-types/src")
        let outputFilePath = join(testProjectSrcPath, "GeneratedPetstoreTypes.res")
        
        Console.log(`📝 Writing generated types to: ${outputFilePath}`)
        
        // Ensure the src directory exists
        if !existsSync(testProjectSrcPath) {
          Console.log("📁 Creating src directory...")
          mkdirSync(testProjectSrcPath, {"recursive": true})
        }
        
        writeFileSync(outputFilePath, moduleCode)
        
        Console.log("✅ Successfully generated Petstore types!")
        Console.log(`📄 Generated ${moduleCode->String.split("\n")->Array.length->Int.toString} lines of ReScript code`)
      }
    }
  } catch {
  | _ => {
      Console.error("❌ Error: Failed to generate types")
      %raw("process.exit(1)")
    }
  }
}

// Main execution
generatePetstoreTypes() 