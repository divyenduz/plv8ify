# search_path Annotation Example

This example demonstrates how to use the `@plv8ify_search_path` JSDoc annotation to set the PostgreSQL `search_path` for generated functions, preventing search_path hijacking vulnerabilities (especially when using `SECURITY DEFINER`).

## JSDoc Annotations

- `/** @plv8ify_search_path */`: Sets `search_path = ''` (empty search path). Recommended for `SECURITY DEFINER` functions to prevent namespace shadowing attacks.
- `/** @plv8ify_search_path <schemas> */`: Sets `search_path` to specific schemas, e.g. `/** @plv8ify_search_path public, extensions */`.
- `/** @plv8ify_searchpath <schemas> */`: Alias without the underscore.

## Running the Example

```bash
bun example:search-path
```
