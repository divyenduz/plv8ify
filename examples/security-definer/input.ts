/**
 * An administrative function that runs with the privileges of the function creator (owner),
 * bypassing Row Level Security (RLS) or permissions of the calling user.
 * @plv8ify_security_definer
 * @plv8ify_volatility VOLATILE
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant authenticated, service_role
 */
export function adminResetUserPassword(userId: string, tempPass: string): boolean {
  return true
}

/**
 * An internal audit log function that specifies SECURITY DEFINER explicitly.
 * @plv8ify_security DEFINER
 * @plv8ify_volatility VOLATILE
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant service_role
 */
export function insertAuditLog(action: string, actorId: string): { success: boolean; timestamp: number } {
  return {
    success: true,
    timestamp: Date.now(),
  }
}

/**
 * A standard user-facing function that explicitly runs under SECURITY INVOKER (caller privileges).
 * @plv8ify_security INVOKER
 * @plv8ify_volatility STABLE
 */
export function getOwnProfile(userId: string): { id: string; name: string } {
  return {
    id: userId,
    name: 'Jane Doe',
  }
}

/**
 * A utility function without security annotations (PostgreSQL defaults to SECURITY INVOKER).
 * @plv8ify_volatility IMMUTABLE
 */
export function formatFullName(firstName: string, lastName: string): string {
  return `${firstName} ${lastName}`
}
