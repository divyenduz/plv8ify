DROP FUNCTION IF EXISTS calculateSum(a float8,b float8);
CREATE OR REPLACE FUNCTION calculateSum(a float8,b float8) RETURNS float8 AS $plv8ify$
// examples/parallel-annotations/input.ts
function calculateSum(a, b) {
  return a + b;
}
function getUserAge(userId) {
  return userId.length * 10;
}
function logMessage(message) {
  console.log(`LOG: ${message}`);
}
function multiply(x, y) {
  return x * y;
}


return calculateSum(a,b)

$plv8ify$ LANGUAGE plv8 IMMUTABLE PARALLEL SAFE STRICT;