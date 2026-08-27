# plv8ify

## 0.0.69

### Patch Changes

- c25a3e4: Remove legacy dead string replacement in `PLV8ifyCLI.build()` and clean up unused `mode` and `scopePrefix` from `BuildArgs`.
- 98be68e: Replace `eval()` with static `ts-morph` AST parsing for custom type maps, supporting TypeScript exports (`export const typeMap`, `export default`), CommonJS, and JSON configuration files securely.
- 60c0e07: Add `--bundle-id` CLI option to allow custom/deterministic bundle identifier for reproducible builds in bundle mode.
- 8d66821: Resolve type names using ts-morph AST symbol inspection instead of string splitting.
- 1a0ea0f: Refactor JSDoc comment extraction to use `ts-morph` AST parsing instead of regular expressions for annotations (`@plv8ify_param`, `@plv8ify_return`, `@plv8ify_returns`, `@plv8ify_volatility`, `@plv8ify_parallel`, `@plv8ify_schema_name`, `@plv8ify_trigger`), providing more robust multiline and whitespace handling.

## 0.0.68

### Patch Changes

- 011c4ce: Update esbuild to latest (`^0.28.2`) to support the TypeScript `satisfies` operator and remove invalid `webpack-node-externals` configuration.

## 0.0.67

### Patch Changes

- 1f0eb62: fix the release CI via OIDC approach, trigger release of other features

## 0.0.66

### Patch Changes

- ca40ed2: Refactor CLI to use @stricli/core instead of arg

  Replaced manual argument parsing with arg package with @stricli/core for better type safety and CLI structure. This is an internal refactoring that maintains backward compatibility - all existing CLI flags and commands work exactly as before.

## 0.0.65

### Patch Changes

- b3a3a7c: Improved CLI help texts and error messages for better user experience:

  - Enhanced the main help message with usage information and command descriptions
  - Improved version command output to include a brief description
  - Made error messages more descriptive and actionable:
    - Better Bun bundler error message with suggested solutions
    - Clearer database connection error messages
    - More informative output folder not found message
    - Improved deploy progress indicators with success/failure symbols
