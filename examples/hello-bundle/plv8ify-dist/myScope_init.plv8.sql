DROP FUNCTION IF EXISTS myScope_init();
CREATE OR REPLACE FUNCTION myScope_init() RETURNS VOID AS $$
// examples/hello-bundle/input.ts
function hello() {
  return "world";
}
function world() {
  return "hello";
}


$$ LANGUAGE plv8 IMMUTABLE STRICT;
