DROP FUNCTION IF EXISTS _init();
CREATE OR REPLACE FUNCTION _init() RETURNS VOID AS $$
// examples/hello-start_proc/input.ts
function hello() {
  return "world";
}
function world() {
  return "hello";
}


$$ LANGUAGE plv8 IMMUTABLE STRICT;
