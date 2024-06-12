DROP FUNCTION IF EXISTS howdy(first_name text,last_name text);
CREATE OR REPLACE FUNCTION howdy(first_name text,last_name text) RETURNS char(255) AS $plv8ify$
// examples/hello-custom-type/input.ts
function hello(test) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age
  };
}
function howdy(first_name, last_name) {
  return `Howdy ${first_name} ${last_name}`;
}


return howdy(first_name,last_name)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;