import { describe, expect, it } from 'bun:test'
import { TsMorph } from './TsMorph'
import fs from 'fs'
import path from 'path'

describe('TsMorph tests', () => {
  it('parses JSDoc annotations with parameter and return overrides', () => {
    const fixturePath = path.resolve('src/test-fixtures/jsdoc-test.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_param {varchar(255)} first_name
 * @plv8ify_param {  text  } last_name
 * @plv8ify_return {  char(255)  }
 * @plv8ify_volatility STABLE
 * @plv8ify_parallel SAFE
 * @plv8ify_schema_name custom_schema
 */
export function fullTest(first_name: string, last_name: string): string {
  return first_name + last_name
}

/**
 * @plv8ify_returns {setof custom_table}
 * @plv8ify_volatility VOLATILE
 * @plv8ify_parallel UNSAFE
 */
export function returnSynonymTest(): any {
  return []
}

/**
 * @plv8ify_trigger
 */
export function triggerTest(NEW: any, OLD: any): any {
  return NEW
}

/**
 * Multiline JSDoc test
 * @plv8ify_param {
 *   numeric(10, 2)
 * } amount
 * @plv8ify_parallel RESTRICTED
 * @plv8ify_volatility IMMUTABLE
 */
export function multilineTest(amount: number): number {
  return amount
}
`
    )

    try {
      const tsMorph = new TsMorph()
      tsMorph.createSourceFile(fixturePath)
      const functions = tsMorph.getFunctions()

      const fullTestFn = functions.find((f) => f.name === 'fullTest')
      expect(fullTestFn).toBeDefined()
      expect(fullTestFn!.isExported).toBe(true)
      expect(fullTestFn!.volatility).toBe('STABLE')
      expect(fullTestFn!.parallel).toBe('SAFE')
      expect(fullTestFn!.customSchema).toBe('custom_schema')
      expect(fullTestFn!.sqlReturnType).toBe('char(255)')
      expect(fullTestFn!.paramTypeOverrides).toEqual({
        first_name: 'varchar(255)',
        last_name: 'text',
      })

      const returnSynonymFn = functions.find((f) => f.name === 'returnSynonymTest')
      expect(returnSynonymFn).toBeDefined()
      expect(returnSynonymFn!.sqlReturnType).toBe('setof custom_table')
      expect(returnSynonymFn!.volatility).toBe('VOLATILE')
      expect(returnSynonymFn!.parallel).toBe('UNSAFE')

      const triggerFn = functions.find((f) => f.name === 'triggerTest')
      expect(triggerFn).toBeDefined()
      expect(triggerFn!.isTrigger).toBe(true)

      const multilineFn = functions.find((f) => f.name === 'multilineTest')
      expect(multilineFn).toBeDefined()
      expect(multilineFn!.paramTypeOverrides).toEqual({
        amount: 'numeric(10, 2)',
      })
      expect(multilineFn!.volatility).toBe('IMMUTABLE')
      expect(multilineFn!.parallel).toBe('RESTRICTED')
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })
})
