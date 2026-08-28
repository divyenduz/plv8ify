# Security Definer & Invoker Annotations Example

This example demonstrates how to use `@plv8ify_security_definer` and `@plv8ify_security` JSDoc annotations to control function execution privileges (`SECURITY DEFINER` vs `SECURITY INVOKER`) in PostgreSQL.

## JSDoc Annotations

- `/** @plv8ify_security_definer */`: Specifies `SECURITY DEFINER` on the generated function. The function executes with the privileges of the user that owns it rather than the user that calls it.
- `/** @plv8ify_security DEFINER */`: Explicitly sets security to `SECURITY DEFINER`.
- `/** @plv8ify_security INVOKER */`: Explicitly sets security to `SECURITY INVOKER` (executes with the privileges of the user that calls it). Also supports `/** @plv8ify_security_invoker */`.

## Running the Example

```bash
bun example:security-definer
```
