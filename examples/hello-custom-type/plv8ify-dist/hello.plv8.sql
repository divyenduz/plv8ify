DROP FUNCTION IF EXISTS hello(test test_type[]);
CREATE OR REPLACE FUNCTION hello(test test_type[]) RETURNS test_type AS $plv8ify$
// examples/hello-custom-type/input.ts
function hello(test) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age
  };
}


return hello(test)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;