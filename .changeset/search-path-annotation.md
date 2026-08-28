---
'plv8ify': minor
---

Add `@plv8ify_search_path` JSDoc annotation to configure PostgreSQL function `search_path`.

- **Hardening `SECURITY DEFINER` functions**: Specifying `/** @plv8ify_search_path */` without arguments automatically defaults to `SET search_path = ''`, satisfying database security best practices and resolving Supabase linter warnings (`0011_function_search_path_mutable`).
- **Custom `search_path`**: Can be set to custom schemas (e.g. `/** @plv8ify_search_path public, extensions */`).
- **Alias support**: Also supports `/** @plv8ify_searchpath */`.
