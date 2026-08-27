---
"plv8ify": patch
---

Replace `eval()` with static `ts-morph` AST parsing for custom type maps, supporting TypeScript exports (`export const typeMap`, `export default`), CommonJS, and JSON configuration files securely.
