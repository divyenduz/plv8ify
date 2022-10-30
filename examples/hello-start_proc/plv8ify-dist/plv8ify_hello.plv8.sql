DROP FUNCTION IF EXISTS plv8ify_hello();
CREATE OR REPLACE FUNCTION plv8ify_hello() RETURNS text AS $plv8ify$

return plv8ify.hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;