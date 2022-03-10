/* IMPORTANT
 * This snapshot file is auto-generated, but designed for humans.
 * It should be checked into source control and tracked carefully.
 * Re-generate by setting TAP_SNAPSHOT=1 and running tests.
 * Make sure to inspect the output below.  Do not ignore changes!
 */
'use strict'
exports[`src/fns/ts-morph/toSQL.test.ts TAP getSQLFunction with delimiter > must match snapshot 1`] = `
DROP FUNCTION IF EXISTS plv8ify_test();
CREATE OR REPLACE FUNCTION plv8ify_test() RETURNS JSONB AS $function$
console.log("hello")
return plv8ify.plv8ify_test()

$function$ LANGUAGE plv8 IMMUTABLE STRICT;
`

exports[`src/fns/ts-morph/toSQL.test.ts TAP getSQLFunction with parameters > must match snapshot 1`] = `
DROP FUNCTION IF EXISTS plv8ify_test();
CREATE OR REPLACE FUNCTION plv8ify_test() RETURNS JSONB AS $plv8ify$
console.log("hello")
return plv8ify.plv8ify_test()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;
`
