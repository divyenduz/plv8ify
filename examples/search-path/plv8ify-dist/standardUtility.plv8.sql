DROP FUNCTION IF EXISTS standardUtility(x float8,y float8);
CREATE OR REPLACE FUNCTION standardUtility(x float8,y float8) RETURNS float8 AS $plv8ify$
// examples/search-path/input.ts
function secureAdminOperation(userId) {
  return true;
}
function queryWithCustomSearchPath(tableName) {
  return `Querying ${tableName}`;
}
function calculateIsolatedHash(input) {
  return `hash_${input}`;
}
function standardUtility(x, y) {
  return x + y;
}

return standardUtility(x,y)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;