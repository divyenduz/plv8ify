/**
 * Public math utility function accessible to all roles (default PostgreSQL permissions)
 * @plv8ify_volatility IMMUTABLE
 */
export function addNumbers(a: number, b: number): number {
  return a + b
}

/**
 * A user operation restricted to specific roles.
 * Execution rights are revoked from PUBLIC and anon, and granted to authenticated and service_role.
 * @plv8ify_revoke PUBLIC
 * @plv8ify_revoke anon
 * @plv8ify_grant authenticated, service_role
 * @plv8ify_volatility STABLE
 */
export function getUserProfile(userId: string): { id: string; role: string } {
  return {
    id: userId,
    role: 'member',
  }
}

/**
 * Admin-only operation with revoked access from PUBLIC/anon/authenticated and granted to admin & superuser.
 * @plv8ify_revokes PUBLIC, anon, authenticated
 * @plv8ify_grants admin, superuser
 * @plv8ify_volatility VOLATILE
 */
export function deleteUserData(userId: string): boolean {
  return true
}
