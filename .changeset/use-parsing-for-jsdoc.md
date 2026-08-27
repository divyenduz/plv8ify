---
"plv8ify": patch
---

Refactor JSDoc comment extraction to use `ts-morph` AST parsing instead of regular expressions for annotations (`@plv8ify_param`, `@plv8ify_return`, `@plv8ify_returns`, `@plv8ify_volatility`, `@plv8ify_parallel`, `@plv8ify_schema_name`, `@plv8ify_trigger`), providing more robust multiline and whitespace handling.
