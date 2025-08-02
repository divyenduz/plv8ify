DROP FUNCTION IF EXISTS myScopeworld();
CREATE OR REPLACE FUNCTION myScopeworld() RETURNS text AS $plv8ify$
if (!globalThis[Symbol.for('myScope_initialized')]!== true) plv8.execute('SELECT myScope_init();');
return world()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;