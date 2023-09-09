DROP FUNCTION IF EXISTS plv8ify_init();
CREATE OR REPLACE FUNCTION plv8ify_init() RETURNS VOID AS $$
// examples/hello-start_proc/input.ts
function hello() {
  return "world";
}
function world() {
  return "hello";
}


$$ LANGUAGE plv8 IMMUTABLE STRICT;
