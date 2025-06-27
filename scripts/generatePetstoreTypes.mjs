// Script to generate Petstore types into test-generated-types folder
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "fs";
import { join, resolve, dirname } from "path";
import { fileURLToPath } from "url";
import { generateModule } from "../src/OpenApiGenerator.res.mjs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function generatePetstoreTypes() {
  console.log("🚀 Starting Petstore type generation...");

  try {
    // Read the Petstore OpenAPI schema
    const petstoreSchemaPath = resolve(
      __dirname,
      "../examples/petstore/openapi.json"
    );
    console.log(`📁 Reading Petstore schema from: ${petstoreSchemaPath}`);

    // Check if file exists
    if (!existsSync(petstoreSchemaPath)) {
      console.error(
        `❌ Petstore schema file not found at: ${petstoreSchemaPath}`
      );
      process.exit(1);
    }

    const openApiJsonString = readFileSync(petstoreSchemaPath, "utf8");
    console.log(
      `✅ Read ${openApiJsonString.length} characters from schema file`
    );

    // Generate the ReScript module
    console.log("🔄 Generating ReScript module...");
    const result = generateModule(openApiJsonString);

    if (result.TAG === "Error") {
      console.error(`❌ Type generation failed: ${result._0}`);
      process.exit(1);
    }

    const moduleCode = result._0;
    console.log("✅ Module generation successful!");

    // Write to test-generated-types/src/GeneratedPetstoreTypes.res
    const testProjectSrcPath = resolve(
      __dirname,
      "../test-generated-types/src"
    );
    const outputFilePath = join(
      testProjectSrcPath,
      "GeneratedPetstoreTypes.res"
    );

    console.log(`📝 Writing generated types to: ${outputFilePath}`);

    // Ensure the src directory exists
    if (!existsSync(testProjectSrcPath)) {
      console.log("📁 Creating src directory...");
      mkdirSync(testProjectSrcPath, { recursive: true });
    }

    writeFileSync(outputFilePath, moduleCode);

    console.log("✅ Successfully generated Petstore types!");
    console.log(
      `📄 Generated ${moduleCode.split("\n").length} lines of ReScript code`
    );
  } catch (error) {
    console.error("❌ Error: Failed to generate types", error.message);
    process.exit(1);
  }
}

// Main execution
generatePetstoreTypes();
