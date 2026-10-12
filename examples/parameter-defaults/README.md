# Parameter Defaults and `@plv8ify_strict` Example

This example demonstrates how a TypeScript parameter default becomes a SQL `DEFAULT` on the generated function, and how the `@plv8ify_strict false` JSDoc annotation declares the function `CALLED ON NULL INPUT` instead of `STRICT`.

## Parameter defaults

A parameter whose initializer is a literal (`null`, a string, a number, `true` or `false`) is declared with the same value as its SQL `DEFAULT`:

- `termLength: string = null` → `termLength text DEFAULT NULL`
- `spDescription: string = '%'` → `spDescription text DEFAULT '%'`
- `page: number = 1` → `page float8 DEFAULT 1`
- `descending: boolean = false` → `descending boolean DEFAULT false`

A caller may then omit the argument, and `CREATE OR REPLACE` can replace an existing function that already carries those defaults (PostgreSQL refuses to drop a default in place). The `DROP FUNCTION` line names types only: a signature never carries defaults.

Any other initializer (`at: string = new Date().toISOString()`) stays in the JavaScript body; the parameter has no SQL default.

## JSDoc Annotation

- `/** @plv8ify_strict false */`: the function is `CALLED ON NULL INPUT`, so it runs when an argument is `NULL`. A `NULL` default that means "any" needs this: a `STRICT` function returns `NULL` without running.
- Without the annotation, or with any other value, the function stays `STRICT`.

## Running the Example

```bash
bun example:parameter-defaults
```
