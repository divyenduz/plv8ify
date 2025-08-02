DROP FUNCTION IF EXISTS myScopehello();
CREATE OR REPLACE FUNCTION myScopehello() RETURNS text AS $plv8ify$
if (globalThis[Symbol.for('myScope_initialized')] !== 1754114242091) plv8.execute('SELECT myScope_init();');
return hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;