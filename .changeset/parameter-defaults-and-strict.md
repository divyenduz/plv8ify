---
'plv8ify': minor
---

Render TypeScript parameter defaults as SQL `DEFAULT`s and add the `@plv8ify_strict` JSDoc annotation.

- **Parameter defaults**: a parameter whose initializer is a literal (`null`, a string, a number, `true` or `false`) is declared with that value as its `DEFAULT` on the `CREATE FUNCTION` line, so callers may omit it and `CREATE OR REPLACE` can replace an existing function that carries the same defaults. The `DROP FUNCTION`, `REVOKE` and `GRANT` signatures stay without defaults, as a signature names types only. Any other initializer stays in the JavaScript body.
- **`@plv8ify_strict false`**: renders `CALLED ON NULL INPUT` instead of `STRICT`, so the function runs on `NULL` arguments (a `NULL` default that means "any" needs this). Without the tag, or with any other value, functions stay `STRICT`.
