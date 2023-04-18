DROP FUNCTION IF EXISTS myScope_hello();
CREATE OR REPLACE FUNCTION myScope_hello() RETURNS text AS $plv8ify$
if (globalThis.myScope === undefined) plv8.execute('SELECT myScope_init();');
return myScope.hello()

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;