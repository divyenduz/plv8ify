/* IMPORTANT
 * This snapshot file is auto-generated, but designed for humans.
 * It should be checked into source control and tracked carefully.
 * Re-generate by setting TAP_SNAPSHOT=1 and running tests.
 * Make sure to inspect the output below.  Do not ignore changes!
 */
'use strict'
exports[`src/impl/EsBuild.test.ts TAP getBundleJs - inline mode > must match snapshot 1`] = `
// src/test-fixtures/input.fixture.ts
function sayHello(toWhom) {
  const greet = \`hello \` + toWhom;
  return greet;
}
export {
  sayHello
};

`

exports[`src/impl/EsBuild.test.ts TAP getBundleJs - newline string > must match snapshot 1`] = `
// src/test-fixtures/newline-string.fixture.ts
function sayHello() {
  const greetString = "hello\\nworld";
  return greetString;
}
export {
  sayHello
};

`

exports[`src/impl/EsBuild.test.ts TAP getBundleJs - newline template > must match snapshot 1`] = `
// src/test-fixtures/newline-template.fixture.ts
function sayHello() {
  const greetTemplate = \`hello 
 world\`;
  return greetTemplate;
}
export {
  sayHello
};

`
