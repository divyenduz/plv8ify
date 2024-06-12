DROP FUNCTION IF EXISTS myScope_init();
CREATE OR REPLACE FUNCTION myScope_init() RETURNS void AS $$
// examples/hello-bundle/input.ts
function hello() {
  return "world";
}
function world() {
  return "hello";
}

globalThis.hello = hello;
globalThis.world = world;
globalThis[Symbol.for('myScope_initialized')] = true;



$$ LANGUAGE plv8 IMMUTABLE STRICT;