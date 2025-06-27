# ReScript OpenAPI Generator

Generate a fully-typed, idiomatic ReScript client from any valid OpenAPI 2/3 specification. The generated output is ready-to-use in ReScript projects and comes with first-class encoders/decoders, endpoint helpers, and exhaustive type safety powered by `rescript-schema` and `rescript-rest`.

---

## Project Status

🚧 **Early planning phase** – the repository currently contains documentation only. The implementation work will start once the initial design has been agreed upon (see [`IMPLEMENTATION_PLAN.md`](./IMPLEMENTATION_PLAN.md)). All APIs, file layouts, and generator options are subject to change.

> **AI-driven build** – this project doubles as an experiment in agent-assisted coding for ReScript. Wherever feasible, the codebase will be generated and evolved by AI tooling, with humans guiding high-level design and reviewing output.

---

## Motivation

Working with REST APIs should feel as effortless and type-safe as working with local modules. By generating strongly-typed bindings directly from an OpenAPI spec we can:

1. **Eliminate runtime errors** caused by mismatched request/response shapes.
2. **Provide auto-completion & refactor-safety** throughout the entire client surface.
3. **Drastically reduce boilerplate** around HTTP calls, validation, and (de)serialization.
4. **Guarantee schema compliance** via compile-time enforcement and exhaustive test suites.

---

## Building Blocks

The generator will leverage the following libraries:

- **`rescript-openapi`** – typed representation of OpenAPI documents.
- **`rescript-schema@9`** – value-level encoders & decoders derived from those types.
- **`rescript-rest`** – higher-level combinators for describing REST endpoints.

Generated clients will be entirely dependency-free beyond these three libraries.

---

## Core Design Principles

- **Idiomatic ReScript first** – prefer familiar ReScript constructs over generic code-gen artefacts.
- **100 % type coverage** – every request, response, path parameter, and header is represented in the type system.
- **Zero-config defaults, full-config power** – sensible defaults with room for advanced overrides.
- **Test-driven development** – every behaviour will be backed by unit & integration tests.

---

## Contributing

Contributions are welcome! Please open an issue to discuss bugs, feature ideas, or questions. For larger changes, start with a design proposal so we can agree on direction before any code is written.
