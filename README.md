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

## Trigger functions

To write a trigger function, decorate the function with the `//@plv8ify-trigger` comment, and have the function return a `testRow` type where `testRow` defines the type of the row for the trigger. You can also add a NEW parameter for insert and update triggers, and OLD for update and delete triggers.
(Tip: you can add @types/pg and @types/plv8-internals to get all standard postgres types/defines and plv8 specific functions recognized by the type checker)

```
type testRow = {
  // Either JS or plv8 types can be used here
  id: number
  event_name: string
  event_date_time: Date
}

//@plv8ify-trigger
export function test(NEW: testRow, OLD: testRow): testRow {
  plv8.elog(NOTICE, 'NEW = ', JSON.stringify(NEW));
  plv8.elog(NOTICE, 'OLD = ', JSON.stringify(OLD));
  plv8.elog(NOTICE, 'TG_OP = ', TG_OP);
  plv8.elog(NOTICE, 'TG_ARGV = ', TG_ARGV);
  if (TG_OP === 'UPDATE') {
    NEW.event_name = NEW.event_name ?? OLD.event_name
    return NEW
  }
  if (TG_OP === 'INSERT') {
    NEW.id = 102
    return NEW
  }
}
```

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
| --bundler               | 'esbuild' or 'bun'                    | Pick bundler. Bun runtime is needed for 'bun'                                                                                                                                                                                                                                           | `esbuild`      |
| --write-bundler-output  | Boolean                               | Write the intermediate bundled Javascript output from bundler (currently, only ESBuild interface exists)                                                                                                                                                                                | `false`        |
| --input-file            | String                                | Specify an input file path (only Typescript supported at the moment)                                                                                                                                                                                                                    | `input.ts`     |
| --output-folder         | String                                | Specify an output folder                                                                                                                                                                                                                                                                | `plv8ify-dist` |
| --scope-prefix          | String                                | Specify a scope prefix, by default `plv8ify`, adds `plv8ify_` as prefix for exported typescript functions                                                                                                                                                                               | `plv8ify`      |
| --pg-function-delimiter | String                                | Specify a delimiter for the generated Postgres function                                                                                                                                                                                                                                 | `$plv8ify$`    |
| --fallback-type         | String                                | Specify a fallback type when `plv8ify` fails to map a detected Typescript type to a Postges type                                                                                                                                                                                        | `JSONB`        |
| --mode                  | 'inline', 'bundle' or 'start_proc'    | 'inline' will bundle the library in each function, both 'bundle' and 'start_proc' creates a `{prefix}_init` function that loads the library. 'bundle' adds a check to each function to call 'init' if required, whereas 'start_proc' is designed to be used with plv8.start_proc        | `inline`       |
| --volatility            | 'IMMUTABLE' or 'STABLE' or 'VOLATILE' | Change the volatility of all the generated functions. To change volatility of a specific function use the comment format `//@plv8ify-volatility-STABLE` in the input typescript file (see `examples/turf-js/input.ts`). Note that for now only single-line comment syntax is supported. | `IMMUTABLE`    |

### Deploy

Deploy an output folder to a Postgres database (defined by env var `DATABASE_URL`)

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
