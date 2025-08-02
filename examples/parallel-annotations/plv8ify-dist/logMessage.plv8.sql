DROP FUNCTION IF EXISTS logMessage(message text);
CREATE OR REPLACE FUNCTION logMessage(message text) RETURNS JSONB AS $plv8ify$
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


return logMessage(message)

$plv8ify$ LANGUAGE plv8 VOLATILE PARALLEL UNSAFE STRICT;