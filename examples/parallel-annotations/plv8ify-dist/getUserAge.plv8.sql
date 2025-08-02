DROP FUNCTION IF EXISTS getUserAge(userId text);
CREATE OR REPLACE FUNCTION getUserAge(userId text) RETURNS float8 AS $plv8ify$
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


return getUserAge(userId)

$plv8ify$ LANGUAGE plv8 STABLE PARALLEL RESTRICTED STRICT;