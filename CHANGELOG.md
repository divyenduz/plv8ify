# plv8ify

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
