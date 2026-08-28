DROP FUNCTION IF EXISTS calculateIsolatedHash(input text);
CREATE OR REPLACE FUNCTION calculateIsolatedHash(input text) RETURNS text AS $plv8ify$
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

return calculateIsolatedHash(input)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT SET search_path = '';