---
"plv8ify": patch
---

Refactor CLI to use @stricli/core instead of arg

Replaced manual argument parsing with arg package with @stricli/core for better type safety and CLI structure. This is an internal refactoring that maintains backward compatibility - all existing CLI flags and commands work exactly as before.