DROP FUNCTION IF EXISTS _init();
CREATE OR REPLACE FUNCTION _init() RETURNS void AS $$
// examples/hello-start_proc/input.ts
function hello() {
  return "world";
}
function world() {
  return "hello";
}
globalThis.hello = hello;
globalThis.world = world;



$$ LANGUAGE plv8 IMMUTABLE STRICT;