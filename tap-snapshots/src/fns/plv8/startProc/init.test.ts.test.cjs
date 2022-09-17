/* IMPORTANT
 * This snapshot file is auto-generated, but designed for humans.
 * It should be checked into source control and tracked carefully.
 * Re-generate by setting TAP_SNAPSHOT=1 and running tests.
 * Make sure to inspect the output below.  Do not ignore changes!
 */
'use strict'
exports[`src/fns/plv8/startProc/init.test.ts TAP getInitFunction > must match snapshot 1`] = `
DROP FUNCTION IF EXISTS plv8ify_init();
CREATE OR REPLACE FUNCTION plv8ify_init() RETURNS VOID AS $$
plv8.elog(NOTICE, plv8.version);
$$ LANGUAGE plv8 IMMUTABLE STRICT;

`

exports[`src/fns/plv8/startProc/init.test.ts TAP getInitFunctionFilename > must match snapshot 1`] = `
plv8ify-dist/init.plv8.sql
`

exports[`src/fns/plv8/startProc/init.test.ts TAP getInitFunctionName > must match snapshot 1`] = `
plv8ify_init
`
