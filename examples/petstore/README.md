# Petstore OpenAPI Example

This directory contains the OpenAPI 3.0.4 specification for the Swagger Petstore API, which we use as a comprehensive test case for the ReScript OpenAPI Generator.

## API Overview

The Petstore API includes three main resource types:

### 🐕 **Pet Operations** (`/pet`)

- **CRUD operations**: Create, read, update, delete pets
- **Search operations**: Find pets by status or tags
- **File upload**: Upload pet images
- **Path parameters**: Pet ID routing
- **Authentication**: OAuth2 and API key

### 🛒 **Store Operations** (`/store`)

- **Inventory management**: Get inventory counts
- **Order management**: Place and manage orders
- **Complex data types**: Maps and relationships

### 👤 **User Operations** (`/user`)

- **User management**: CRUD for user accounts
- **Authentication**: Login/logout functionality
- **Batch operations**: Create multiple users
- **Path parameters**: Username routing

## Schema Complexity

The API includes several data types that will test our generator:

- **Enums**: Pet status, order status
- **Required fields**: Pet name and photoUrls
- **Object relationships**: Pet → Category, Pet → Tags[]
- **Arrays**: Photo URLs, tags, user lists
- **Nested objects**: Complex object hierarchies
- **Different formats**: int64, int32, date-time, binary
- **Optional fields**: Most fields are optional

## Test Coverage Goals

This specification will help us test:

✅ **Type Generation**:

- Primitive types (string, number, boolean)
- Enums with string values
- Object types with required/optional fields
- Array types
- Nested object references ($ref)

✅ **Endpoint Generation**:

- HTTP methods (GET, POST, PUT, DELETE)
- Path parameters (`/pet/{petId}`)
- Query parameters (`?status=available`)
- Request bodies (JSON/XML/form-data)
- Response types with different status codes
- Authentication schemes

✅ **Edge Cases**:

- File uploads (binary data)
- Multiple content types
- Default responses
- Header parameters
- Security requirements

## Files

- `openapi.json` - The complete OpenAPI 3.0.4 specification
- `README.md` - This documentation

## Usage

This specification will be consumed by our generator to produce:

1. ReScript type definitions for all schemas
2. rescript-schema encoders/decoders
3. rescript-rest endpoint definitions
4. A complete, type-safe client library
