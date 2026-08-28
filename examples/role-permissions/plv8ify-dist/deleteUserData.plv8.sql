DROP FUNCTION IF EXISTS deleteUserData(userId text);
CREATE OR REPLACE FUNCTION deleteUserData(userId text) RETURNS boolean AS $plv8ify$
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

return deleteUserData(userId)

$plv8ify$ LANGUAGE plv8 VOLATILE STRICT;
REVOKE EXECUTE ON FUNCTION deleteUserData(userId text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION deleteUserData(userId text) TO admin, superuser;