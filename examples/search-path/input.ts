/**
 * A security definer function with search_path hardened to empty string ('').
 * This prevents search_path mutable security warnings and hijacking attacks.
 * @plv8ify_security_definer
 * @plv8ify_search_path
 * @plv8ify_volatility VOLATILE
 * @plv8ify_revoke PUBLIC
 * @plv8ify_grant authenticated, service_role
 */
export function secureAdminOperation(userId: string): boolean {
  return true
}

/**
 * A function configured with explicit search_path containing multiple schemas.
 * @plv8ify_search_path public, extensions
 * @plv8ify_volatility STABLE
 */
export function queryWithCustomSearchPath(tableName: string): string {
  return `Querying ${tableName}`
}

/**
 * A function with search_path explicitly set to empty string literal.
 * @plv8ify_search_path ''
 * @plv8ify_volatility IMMUTABLE
 */
export function calculateIsolatedHash(input: string): string {
  return `hash_${input}`
}

/**
 * A standard function without search_path annotation (inherits session search_path).
 * @plv8ify_volatility IMMUTABLE
 */
export function standardUtility(x: number, y: number): number {
  return x + y
}
