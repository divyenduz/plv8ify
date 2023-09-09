DROP FUNCTION IF EXISTS plv8ify_world();
CREATE OR REPLACE FUNCTION plv8ify_world() RETURNS text AS $plv8ify$

return world()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;