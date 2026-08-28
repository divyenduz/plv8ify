DROP FUNCTION IF EXISTS getOwnProfile(userId text);
CREATE OR REPLACE FUNCTION getOwnProfile(userId text) RETURNS JSONB AS $plv8ify$
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

return getOwnProfile(userId)

$plv8ify$ LANGUAGE plv8 STABLE STRICT SECURITY INVOKER;