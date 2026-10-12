---
'plv8ify': minor
---

Render TypeScript parameter defaults as SQL `DEFAULT`s and add the `@plv8ify_strict` JSDoc annotation.

- **Parameter defaults**: the contiguous suffix of parameters with literal initializers (`null`, a string, a number, `true` or `false`) is declared with those decoded values as `DEFAULT`s on the `CREATE FUNCTION` line. Earlier parameters stay required in SQL, because PostgreSQL requires all inputs following a default to have defaults too. String escapes and numeric literal spellings retain their JavaScript values. The `DROP FUNCTION`, `REVOKE` and `GRANT` signatures stay without defaults. Other initializers stay in the JavaScript body.
- **`@plv8ify_strict false`**: renders `CALLED ON NULL INPUT` instead of `STRICT`, so the function runs on `NULL` arguments (a `NULL` default that means "any" needs this). Without the tag, or with any other value, functions stay `STRICT`.
