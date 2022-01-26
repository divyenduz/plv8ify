# PLV8ify

## Introduction

## How

1. Sample input.js

```js
const { point: turfPoint } = require("@turf/helpers");

function main() {
  const pt = turfPoint([-77.032, 38.913]);
  return pt;
}

console.log(main());
```

2. Run `rm plv8.sql; node index.js > plv8.sql`
3. Run the generated `plv8.sql` using a Postgres client
4. Call the generated function using a Postgres client `SELECT plv8_test();`

## TODO

- [ ] Custom function name
- [ ] Input arguments
- [ ] Input file name
- [ ] Output file name
- [ ] Intermediate file name
- [ ] Remove intermediate file
- [ ] Return type guessing
- [ ] Typescript
- [ ] Stuff
