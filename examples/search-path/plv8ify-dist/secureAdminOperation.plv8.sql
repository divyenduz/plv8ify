DROP FUNCTION IF EXISTS secureAdminOperation(userId text);
CREATE OR REPLACE FUNCTION secureAdminOperation(userId text) RETURNS boolean AS $plv8ify$
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

return secureAdminOperation(userId)

$plv8ify$ LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER SET search_path = '';
REVOKE EXECUTE ON FUNCTION secureAdminOperation(userId text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION secureAdminOperation(userId text) TO authenticated, service_role;