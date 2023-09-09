DROP FUNCTION IF EXISTS myScope_world();
CREATE OR REPLACE FUNCTION myScope_world() RETURNS text AS $plv8ify$
if (globalThis.myScope === undefined) plv8.execute('SELECT myScope_init();');
return world()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;