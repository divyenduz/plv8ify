# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

PLV8ify is a TypeScript/JavaScript bundler that generates PostgreSQL functions using PLV8. It transforms TypeScript code into SQL functions that can run directly in PostgreSQL databases.

## Key Commands

### Development
- `bun test` - Run tests using Bun test runner
- `bun run build` - Build the project (compiles TypeScript to dist/)
- `bun run dev` - Run the turf-js example in development mode

### Testing
- `bun test` - Run all tests
- `bun test [filename]` - Run specific test file

### Examples
- `bun examples` - Run all examples
- `bun example:hello` - Run basic hello world example
- `bun example:turf-js` - Run turf.js integration example
- `bun example:trigger` - Run trigger function example

## Architecture

### Core Components

1. **CLI Entry Point** (`src/index.ts`)
   - Detects runtime (Bun or Node.js)
   - Routes to commands: `generate`, `deploy`, `version`

2. **Command Processors** (`src/commands/`)
   - `generate.ts` - Main command that bundles TS/JS and generates SQL files
   - `deploy.ts` - Deploys generated SQL to PostgreSQL (uses DATABASE_URL env)
   - `version.ts` - Shows version info

3. **Bundler Interface** (`src/interfaces/Bundler.ts`)
   - Abstraction for bundling strategies
   - Implementations: `EsBuild.ts` (default), `BunBuild.ts`

4. **TypeScript Compiler** (`src/impl/TsMorph.ts`)
   - Uses ts-morph to parse TypeScript AST
   - Extracts function signatures, parameters, JSDoc tags

5. **PLV8ify Core** (`src/impl/PLV8ifyCLI.ts`)
   - Orchestrates the transformation pipeline
   - Handles type mapping (TS → PostgreSQL)
   - Generates SQL function wrappers
   - Supports multiple modes: `inline`, `bundle`, `start_proc`

### Type System

- Default type mappings: `number` → `float8`, `string` → `text`, `boolean` → `boolean`
- Custom type mappings via `types.ts` configuration file
- JSDoc annotations for per-function customization:
  - `@plv8ify_param` - Override parameter types
  - `@plv8ify_return` - Override return type
  - `@plv8ify_volatility` - Set function volatility
  - `@plv8ify_schema_name` - Deploy to custom schema
  - `@plv8ify_trigger` - Mark as trigger function

### Build Process Flow

1. Parse CLI arguments
2. Initialize TypeScript compiler with input file
3. Extract exported functions and their metadata
4. Bundle JavaScript code (with dependencies)
5. Generate SQL files with PLV8 function wrappers
6. Write SQL files to output directory

## Testing

Tests use Bun's built-in test runner with snapshot testing for SQL generation. Test files are colocated with implementation files (`.test.ts` suffix).

## Important Notes

- Project uses Bun as primary runtime but maintains Node.js compatibility
- TypeScript config uses ESNext modules with Bun types
- All SQL functions default to IMMUTABLE unless specified
- Generated functions use configurable delimiters (default: `$plv8ify$`)