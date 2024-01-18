DROP FUNCTION IF EXISTS plv8ify_hello();
CREATE OR REPLACE FUNCTION plv8ify_hello() RETURNS text AS $plv8ify$
// input.ts
function hello() {
  return "world";
}


return hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;