declare const ENABLE_FEATURE: boolean;

export function test_define_flag(input: string): string {
  if (!ENABLE_FEATURE) return input;
  const result = 'feature active: ' + input;
  return result;
}
