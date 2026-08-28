DROP FUNCTION IF EXISTS queryWithCustomSearchPath(tableName text);
CREATE OR REPLACE FUNCTION queryWithCustomSearchPath(tableName text) RETURNS text AS $plv8ify$
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

return queryWithCustomSearchPath(tableName)

$plv8ify$ LANGUAGE plv8 STABLE STRICT SET search_path = public, extensions;