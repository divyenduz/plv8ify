/**
 * Term resolution over a small vocabulary: a null length or payment option means "any",
 * so the function must run on NULL arguments (CALLED ON NULL INPUT) and the defaults must
 * reach SQL, so a caller may omit them and CREATE OR REPLACE keeps an existing signature.
 * @plv8ify_strict false
 * @plv8ify_volatility IMMUTABLE
 */
export function resolveTermKeys(
  purchaseOption: string,
  termLength: string = null,
  paymentOption: string = null,
  spDescription: string = '%',
): string {
  const terms = [
    { key: 'on_demand', purchase: 'on_demand', length: '', payment: '' },
    { key: 'reserved_1yr_no_upfront', purchase: 'reserved', length: '1yr', payment: 'No Upfront' },
    { key: 'reserved_3yr_all_upfront', purchase: 'reserved', length: '3yr', payment: 'All Upfront' },
    { key: 'savings_plan_compute_1yr_no_upfront', purchase: 'savings_plan', length: '1yr', payment: 'No Upfront' },
  ]
  const like = (subject: string, pattern: string) =>
    new RegExp(`^${pattern.replace(/[.*+?^${}()|[\]\\]/g, '\\$&').replace(/%/g, '.*')}$`).test(subject)
  return terms
    .filter((t) => t.purchase === purchaseOption)
    .filter((t) => purchaseOption === 'on_demand' || like(t.length, `${termLength ?? ''}%`))
    .filter((t) => purchaseOption === 'on_demand' || like(t.payment, `${paymentOption ?? ''}%`))
    .filter((t) => purchaseOption !== 'savings_plan' || like(t.key, spDescription))
    .map((t) => t.key)
    .join(',')
}

/**
 * Numbers and booleans are literals too; STRICT stays the default.
 * @plv8ify_volatility IMMUTABLE
 */
export function paginate(page: number = 1, pageSize: number = 25, descending: boolean = false): string {
  return `${page}/${pageSize}/${descending ? 'desc' : 'asc'}`
}

/**
 * Only a literal initializer becomes a DEFAULT: an expression stays in the JavaScript body,
 * and the parameter is required on the SQL side.
 * @plv8ify_volatility VOLATILE
 */
export function stamp(label: string, at: string = new Date().toISOString()): string {
  return `${label}@${at}`
}
