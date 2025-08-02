DROP FUNCTION IF EXISTS multiply(x float8,y float8);
CREATE OR REPLACE FUNCTION multiply(x float8,y float8) RETURNS float8 AS $plv8ify$
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


return multiply(x,y)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;