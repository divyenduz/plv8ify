DROP FUNCTION IF EXISTS hello();
CREATE OR REPLACE FUNCTION hello() RETURNS text AS $plv8ify$
// examples/hello/input.ts
function hello() {
  return "world";
}


return hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;