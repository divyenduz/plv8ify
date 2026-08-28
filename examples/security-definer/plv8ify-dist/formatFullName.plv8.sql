DROP FUNCTION IF EXISTS formatFullName(firstName text,lastName text);
CREATE OR REPLACE FUNCTION formatFullName(firstName text,lastName text) RETURNS text AS $plv8ify$
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

return formatFullName(firstName,lastName)

$plv8ify$ LANGUAGE plv8 IMMUTABLE STRICT;