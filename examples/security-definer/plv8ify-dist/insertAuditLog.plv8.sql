DROP FUNCTION IF EXISTS insertAuditLog(action text,actorId text);
CREATE OR REPLACE FUNCTION insertAuditLog(action text,actorId text) RETURNS JSONB AS $plv8ify$
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

return insertAuditLog(action,actorId)

$plv8ify$ LANGUAGE plv8 VOLATILE STRICT SECURITY DEFINER;
REVOKE EXECUTE ON FUNCTION insertAuditLog(action text,actorId text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION insertAuditLog(action text,actorId text) TO service_role;