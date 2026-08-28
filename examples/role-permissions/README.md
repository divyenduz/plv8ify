# Role Permissions (GRANT & REVOKE) Example

This example demonstrates how to use `@plv8ify_grant` and `@plv8ify_revoke` JSDoc annotations to manage PostgreSQL execution permissions for roles.

## JSDoc Annotations

- `@plv8ify_revoke <roles>`: Revokes `EXECUTE` rights on the generated PostgreSQL function from specified roles (e.g. `PUBLIC`, `anon`). Also supports plural synonym `@plv8ify_revokes`.
- `@plv8ify_grant <roles>`: Grants `EXECUTE` rights on the generated PostgreSQL function to specified roles (e.g. `authenticated`, `service_role`). Also supports plural synonym `@plv8ify_grants`.

You can provide comma-separated role names and/or use multiple annotations on the same function.

## Running the Example

```bash
bun example:role-permissions
```
