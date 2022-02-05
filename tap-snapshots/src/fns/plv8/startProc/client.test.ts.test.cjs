/* IMPORTANT
 * This snapshot file is auto-generated, but designed for humans.
 * It should be checked into source control and tracked carefully.
 * Re-generate by setting TAP_SNAPSHOT=1 and running tests.
 * Make sure to inspect the output below.  Do not ignore changes!
 */
'use strict'
exports[`src/fns/plv8/startProc/client.test.ts TAP getClientInitFileName > must match snapshot 1`] = `
plv8ify-dist/start.plv8.sql
`

exports[`src/fns/plv8/startProc/client.test.ts TAP getClientInitSQL > must match snapshot 1`] = `
SET plv8.start_proc = plv8ify_init;
SELECT plv8_reset();
`
