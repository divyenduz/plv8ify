# PLV8ify

## Introduction

`plv8ify` bundles typescript/javascript input and writes SQL file(s) containing Postgres functions using PLV8.

## Why

- Interchange code between API and Database
- Write code in Typescript and use it in Postgres

## Example

1. `npm install -g plv8ify`
2. Sample input.ts

```js
const { point: turfPoint } = require("@turf/helpers");

export function point(lat, long) {
  const pt = turfPoint([lat, long]);
  return pt;
}
```

3. Run `plv8ify generate`
4. Step 3 emits SQL file with names like `./plv8-dist/plv8ify_point.plv8.sql` (one for each exported function)
5. Execute the generated `./plv8-dist/plv8ify_point.plv8.sql` using a Postgres client
6. Call the generated function using a Postgres client `SELECT plv8ify_point(52.5200,13.4050);`
7. Steps 1-6 converted a Typescript file into a PLV8 executable function

## CLI Arguments

| Generate Command Flags | Type    | Description                                                                                              | Default        |
| ---------------------- | ------- | -------------------------------------------------------------------------------------------------------- | -------------- |
| --write-esbuild-output | Boolean | Write the intermediate bundled Javascript output from ESBuild                                            | `false`        |
| --input-file           | String  | Specify an input file path (only Typescript supported at the moment)                                     | `input.ts`     |
| --output-folder        | String  | Specify an output folder                                                                                 | `plv8ify-dist` |
| --scope-prefix         | String  | Specify a scope prefix, by default `plv8ify` adds `plv8ify_` as prefix for exported typescript functions | `plv8ify`      |
| --fallback-type        | String  | Specify a fallback type when `plv8ify` fails to map a detected Typescript type to a Postges type         | `JSONB`        |

## TODO

- [ ] README
- [x] Custom function name
- [x] Export multiple functions
- [x] Input arguments - basic setup
- [x] Flag to Emit intermediate file
- [ ] Input arguments - support most data types
- [x] Input file name
- [x] Output folder name
- [ ] Return type guessing
- [x] Typescript as input
- [ ] Javascript as input
- [ ] Typescript for plv8ify code
- [ ] For each exported bundle, use tree-shaken bundle, currently, each bundle gets all of the Javascript
- [ ] Test cases

## Caveats

- Very early, only a small number of types supported
- Only supports typescript as input at the moment
- Scaling an application server is easier than scaling a database server, moving the logic in database as postgres functions makes it easier (IMO SQL is declarative, like React for data) to call the code/do some things but you are effectively shifting compute from application server to database server which might be a bad idea in most cases.

## Prior Art

- https://github.com/CSTARS/es6-to-plv8
- https://github.com/clkao/plv8x

## Contact

If you want to reach out to me, please DM me on https://twitter.com/divyenduz or email me at `mail at divyendusingh.com`
