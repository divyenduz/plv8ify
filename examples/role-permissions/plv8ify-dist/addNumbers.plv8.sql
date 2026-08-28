DROP FUNCTION IF EXISTS addNumbers(a float8,b float8);
CREATE OR REPLACE FUNCTION addNumbers(a float8,b float8) RETURNS float8 AS $plv8ify$
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

return addNumbers(a,b)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;