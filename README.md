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

## Deploy on custom schema

To generate a function to be deployed on a schema different than the default one (usually: public) decorate the function with a `/** @plv8ify_schema_name <schemaname> */` jsdoc tag

```ts
/** @plv8ify_schema_name testschema */
export function hello() {
  return 'world'
}
```

will generate

```sql
DROP FUNCTION IF EXISTS testschema.plv8ify_hello();
CREATE OR REPLACE FUNCTION testschema.plv8ify_hello() RETURNS text AS $plv8ify$
// input.ts
function hello() {
  return "world";
}


return hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;
```

## Trigger functions

To write a trigger function, decorate the function with a `/** @plv8ify_trigger */` jsdoc tag, and have the function return a `testRow` type where `testRow` defines the type of the row for the trigger. You can also add a NEW parameter for insert and update triggers, and OLD for update and delete triggers.
(Tip: you can add @types/pg and @types/plv8-internals to get all standard postgres types/defines and plv8 specific functions recognized by the type checker)

```ts
type Row = {
  // Either JS or plv8 types can be used here
  id: number
  event_name: string
  event_date_time: Date
}

/** @plv8ify_trigger */
export function test(NEW: Row, OLD: Row): Row {
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

## Custom Postgres Types

By default plv8ify converts typescript types to postgres types using the following map:

```
  private _typeMap = {
    number: 'float8',
    string: 'text',
    boolean: 'boolean',
  }
```

and defaults all other types to either JSONB or the type passed in using the `--fallback-type option`
It is possible to define additional type mapping by using a custom file (by default `types.ts`) with the following format:

```
typeMap = {
  test_type: 'test_type',
  'test_type[]': 'test_type[]',
}
```

The custom types will be merged with the default ones at runtime and will allow using either internal postgres type or custom defined types

Example:

types.ts

```ts
typeMap = {
  test_type: 'test_type',
  'test_type[]': 'test_type[]',
}
```

input.ts

```ts
interface test_type {
  name: string
  age: number
}

export function hello(test: test_type[]) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age,
  }
}

```

cli command line:

```
plv8ify generate input.ts --types-config-file types.ts
```

will generate this function:

```sql
DROP FUNCTION IF EXISTS plv8ify_hello(test test_type[]);
CREATE OR REPLACE FUNCTION plv8ify_hello(test test_type[]) RETURNS JSONB AS $plv8ify$
// input.ts
function hello(test) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age
  };
}


return hello(test)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;
```

Additionally, you can decorate your functions with special jsdoc tags to control the type mapping of params and return types on a per function basis:

Example:

input.ts

```ts
/**
 * @plv8ify_param {varchar(255)} first_name
 * @plv8ify_param {text} last_name
 * @plv8ify_return {char(255)}
 */
export function howdy(first_name: string, last_name: string): string {
  return `Howdy ${first_name} ${last_name}`
}
```

cli command line:

```
plv8ify generate input.ts
```

will generate this function:

```sql
DROP FUNCTION IF EXISTS howdy(first_name varchar(255),last_name text);
CREATE OR REPLACE FUNCTION howdy(first_name varchar(255),last_name text) RETURNS char(255) AS $plv8ify$
// examples/hello-custom-type/input.ts
function hello(test) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age
  };
}
function howdy(first_name, last_name) {
  return `Howdy ${first_name} ${last_name}`;
}


return howdy(first_name,last_name)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;
```

### JSDoc Tag Reference

| Behavior | JSDoc Tag | Example |
| -------- | --------- | ------------- |
| set the volatility of the generated Postgres function | `/** @plv8ify_volatility <STABLE,IMMUTABLE,VOLATILE> */` | `/** @plv8ify_volatility STABLE */` |
| set the schema of the generated Postgres function | `/** @plv8ify_schema_name <schemaname> */` | `/** @plv8ify_schema_name my_schema */` |
| set the TS->SQL type mapping for a parameter | `/** @plv8ify_param {<my_sql_type>} <my_param> */` | `/** @plv8ify_param {timestamptz} ts */` |
| set the TS->SQL type mapping for the return type | `/** @plv8ify_returns {<SQL TYPE>} */` | `/** @plv8ify_returns {setof my_table} */` |
| designate the function is a TRIGGER | `/** @plv8ify_trigger */` | `/** @plv8ify_trigger */` |

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
| --scope-prefix          | String                                | Specify a scope prefix, by default `(empty string)`, adds provided string as prefix for exported typescript functions                                                                                                                                                                   | `plv8ify`      |
| --pg-function-delimiter | String                                | Specify a delimiter for the generated Postgres function                                                                                                                                                                                                                                 | `$plv8ify$`    |
| --fallback-type         | String                                | Specify a fallback type when `plv8ify` fails to map a detected Typescript type to a Postges type                                                                                                                                                                                        | `JSONB`        |
| --mode                  | 'inline', 'bundle' or 'start_proc'    | 'inline' will bundle the library in each function, both 'bundle' and 'start_proc' creates a `{prefix}_init` function that loads the library. 'bundle' adds a check to each function to call 'init' if required, whereas 'start_proc' is designed to be used with plv8.start_proc        | `inline`       |
| --volatility            | 'IMMUTABLE' or 'STABLE' or 'VOLATILE' | Change the volatility of all the generated functions. To change volatility of a specific function use the jsdoc `/** @plv8ify_volatility STABLE` in the input typescript file (see `examples/turf-js/input.ts`).                                                                        | `IMMUTABLE`    |
| --types-config-file     | String                                | Specify a custom types config file                                                                                                                                                                                                                                                      | types.ts       |

### Deploy

Deploy an output folder to a Postgres database (defined by env var `DATABASE_URL`)

| Generate Command Flags | Type   | Description                                                             | Default        |
| ---------------------- | ------ | ----------------------------------------------------------------------- | -------------- |
| --output-folder        | String | Specify an output folder                                                | `plv8ify-dist` |
| --deploy-concurrency   | Number | Specify the maximum allowed deployment tasks to run in parallel         | 10             |

## Development Setup

### Local Development

This project uses [Lefthook](https://github.com/evilmartians/lefthook) for Git hooks to ensure code quality and maintain consistency.

#### Initial Setup

1. Clone the repository
2. Install dependencies: `bun install`
3. Lefthook will be automatically installed via the `prepare` script

#### Git Hooks

The following hooks are configured:

- **pre-commit**: Automatically updates `bun.lock` when `package.json` changes
- **post-checkout/post-merge**: Automatically runs `bun install` when `package.json` changes after switching branches or merging

#### Running Checks Manually

You can run CI checks locally before pushing:

```bash
# Run all CI checks (typecheck, tests, lockfile verification)
bun run lefthook run pre-push

# Run specific checks
bun run lefthook run pre-push --commands typecheck
bun run lefthook run pre-push --commands tests
```

### CI Setup

The project uses GitHub Actions for continuous integration. Lefthook runs the following checks in CI:

1. **TypeScript type checking**: Ensures no type errors
2. **Tests**: Runs all test suites
3. **Lockfile verification**: Ensures `bun.lock` is in sync with `package.json`

To add Lefthook to your CI workflow, add this step:

```yaml
- name: Run Lefthook CI Checks
  run: bun run lefthook run pre-push --no-tty
```

### Troubleshooting

If hooks aren't working:

1. Reinstall hooks: `bun run lefthook install`
2. Check hook status: `bun run lefthook run pre-commit --verbose`
3. Skip hooks temporarily: `LEFTHOOK_SKIP=1 git commit -m "message"`

## Caveats

- Very early, only a small number of types supported
- Only supports typescript as input at the moment
- Scaling an application server is easier than scaling a database server, moving the logic in database as postgres functions makes it easier (IMO SQL is declarative, like React for data) to call the code/do some things but you are effectively shifting compute from application server to database server which might be a bad idea in most cases.

## Prior Art

- https://github.com/CSTARS/es6-to-plv8
- https://github.com/clkao/plv8x

## Contact

If you want to reach out to me, please DM me on https://twitter.com/divyenduz or email me at `mail at divyendusingh.com`
