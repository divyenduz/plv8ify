DROP FUNCTION IF EXISTS hello(test JSONB);
CREATE OR REPLACE FUNCTION hello(test JSONB) RETURNS JSONB AS $plv8ify$
// examples/common-types/input.ts
function hello(test) {
  return {
    name: `Hello ${test[0].name}`,
    age: test[0].age
  };
}


return hello(test)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;