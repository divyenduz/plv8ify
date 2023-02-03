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
const { point: turfPoint } = require('@turf/helpers')

export function point(lat, long) {
  const pt = turfPoint([lat, long])
  return pt
}
```

3. Run `plv8ify generate`
4. Step 3 emits SQL file with names like `./plv8-dist/plv8ify_point.plv8.sql` (one for each exported function)
5. Execute the generated `./plv8-dist/plv8ify_point.plv8.sql` using a Postgres client
6. Call the generated function using a Postgres client `SELECT plv8ify_point(52.5200,13.4050);`

See all examples in the [examples folder](/examples). Use `yarn examples` to apply any changes to all the examples.

## CLI Usage

### Version

Print the version

| Generate Command Flags | Type | Description | Default |
| ---------------------- | ---- | ----------- | ------- |

### Generate

Generate PLV8 functions for an input typescript file

| Generate Command Flags  | Type                                  | Description                                                                                                                                                                                                                                                                             | Default        |
| ----------------------- | ------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
| --debug                 | Boolean                               | Print additional debug information                                                                                                                                                                                                                                                      | `false`        |
| --write-bundler-output  | Boolean                               | Write the intermediate bundled Javascript output from bundler (currently, only ESBuild interface exists)                                                                                                                                                                                | `false`        |
| --input-file            | String                                | Specify an input file path (only Typescript supported at the moment)                                                                                                                                                                                                                    | `input.ts`     |
| --output-folder         | String                                | Specify an output folder                                                                                                                                                                                                                                                                | `plv8ify-dist` |
| --scope-prefix          | String                                | Specify a scope prefix, by default `plv8ify`, adds `plv8ify_` as prefix for exported typescript functions                                                                                                                                                                               | `plv8ify`      |
| --pg-function-delimiter | String                                | Specify a delimiter for the generated Postgres function                                                                                                                                                                                                                                 | `$plv8ify$`    |
| --fallback-type         | String                                | Specify a fallback type when `plv8ify` fails to map a detected Typescript type to a Postges type                                                                                                                                                                                        | `JSONB`        |
| --mode                  | 'inline' or 'start_proc'              | Bundle the library inline in each function or bundle the libary to be used with plv8.start_proc                                                                                                                                                                                         | `inline`       |
| --volatility            | 'IMMUTABLE' or 'STABLE' or 'VOLATILE' | Change the volatility of all the generated functions. To change volatility of a specific function use the comment format `//@plv8ify-volatility-STABLE` in the input typescript file (see `examples/turf-js/input.ts`). Note that for now only single-line comment syntax is supported. | `IMMUTABLE`    |

### Deploy

Deploy an output folder to a Postgres database

| Generate Command Flags | Type   | Description              | Default        |
| ---------------------- | ------ | ------------------------ | -------------- |
| --output-folder        | String | Specify an output folder | `plv8ify-dist` |

## Caveats

- Very early, only a small number of types supported
- Only supports typescript as input at the moment
- Scaling an application server is easier than scaling a database server, moving the logic in database as postgres functions makes it easier (IMO SQL is declarative, like React for data) to call the code/do some things but you are effectively shifting compute from application server to database server which might be a bad idea in most cases.

## Prior Art

- https://github.com/CSTARS/es6-to-plv8
- https://github.com/clkao/plv8x

## Contact

If you want to reach out to me, please DM me on https://twitter.com/divyenduz or email me at `mail at divyendusingh.com`
