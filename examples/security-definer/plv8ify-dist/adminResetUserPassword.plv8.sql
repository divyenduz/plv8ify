DROP FUNCTION IF EXISTS adminResetUserPassword(userId text,tempPass text);
CREATE OR REPLACE FUNCTION adminResetUserPassword(userId text,tempPass text) RETURNS boolean AS $plv8ify$
// examples/security-definer/input.ts
function adminResetUserPassword(userId, tempPass) {
  return true;
}
function insertAuditLog(action, actorId) {
  return {
    success: true,
    timestamp: Date.now()
  };
}
function getOwnProfile(userId) {
  return {
    id: userId,
    name: "Jane Doe"
  };
}
function formatFullName(firstName, lastName) {
  return `${firstName} ${lastName}`;
}

return adminResetUserPassword(userId,tempPass)

$plv8ify$ LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER;
REVOKE EXECUTE ON FUNCTION adminResetUserPassword(userId text,tempPass text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION adminResetUserPassword(userId text,tempPass text) TO authenticated, service_role;