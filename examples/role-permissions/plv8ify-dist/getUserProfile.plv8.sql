DROP FUNCTION IF EXISTS getUserProfile(userId text);
CREATE OR REPLACE FUNCTION getUserProfile(userId text) RETURNS JSONB AS $plv8ify$
// examples/role-permissions/input.ts
function addNumbers(a, b) {
  return a + b;
}
function getUserProfile(userId) {
  return {
    id: userId,
    role: "member"
  };
}
function deleteUserData(userId) {
  return true;
}

return getUserProfile(userId)

$plv8ify$ LANGUAGE plv8 STABLE STRICT;
REVOKE EXECUTE ON FUNCTION getUserProfile(userId text) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION getUserProfile(userId text) TO authenticated, service_role;