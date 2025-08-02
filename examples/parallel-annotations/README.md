# PARALLEL Annotations Example

This example demonstrates how to use the `@plv8ify_parallel` annotation to control parallel execution safety of PostgreSQL functions.

## Available PARALLEL Options

PostgreSQL supports three levels of parallel safety:

1. **PARALLEL SAFE** - The function can be executed in parallel without any restrictions. Use this for pure functions that don't access shared state.
   ```typescript
   /** @plv8ify_parallel SAFE */
   ```

2. **PARALLEL RESTRICTED** - The function can be executed in parallel, but with some restrictions. It cannot access temporary tables, client connection state, cursors, or prepared statements.
   ```typescript
   /** @plv8ify_parallel RESTRICTED */
   ```

3. **PARALLEL UNSAFE** - The function cannot be executed in parallel. Use this for functions that modify database state or have side effects.
   ```typescript
   /** @plv8ify_parallel UNSAFE */
   ```

## Example Usage

See `input.ts` for examples of each annotation type. When you run PLV8ify, it will generate SQL functions with the appropriate PARALLEL clause.

## Running the Example

```bash
bun run plv8ify:inline
# or
npm run plv8ify:inline
```

This will generate SQL files in the `plv8-generated` directory with the correct PARALLEL clauses.