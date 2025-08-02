/**
 * A function marked as PARALLEL SAFE - can be executed in parallel without any issues
 * This is typically used for pure functions that don't access shared state
 * @plv8ify_parallel SAFE
 */
export function calculateSum(a: number, b: number): number {
  return a + b;
}

/**
 * A function marked as PARALLEL RESTRICTED - has limited parallel execution
 * This might access some shared resources but in a controlled manner
 * @plv8ify_parallel RESTRICTED
 * @plv8ify_volatility STABLE
 */
export function getUserAge(userId: string): number {
  // In a real scenario, this might query a cache or do some limited I/O
  // For demo purposes, we'll just return a calculated value
  return userId.length * 10;
}

/**
 * A function marked as PARALLEL UNSAFE - cannot be executed in parallel
 * This is used for functions that modify shared state or have side effects
 * @plv8ify_parallel UNSAFE
 * @plv8ify_volatility VOLATILE
 */
export function logMessage(message: string): void {
  // In a real scenario, this might write to a log file or update global state
  // For demo purposes, we'll just use console.log
  console.log(`LOG: ${message}`);
}

/**
 * A function without parallel annotation - will not have PARALLEL clause
 * @plv8ify_volatility IMMUTABLE
 */
export function multiply(x: number, y: number): number {
  return x * y;
}