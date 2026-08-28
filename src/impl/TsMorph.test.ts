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

  it('parses grant and revoke JSDoc annotations correctly', () => {
    const fixturePath = path.resolve('src/test-fixtures/grants-test.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_revoke PUBLIC
 * @plv8ify_revoke anon
 * @plv8ify_grant authenticated, service_role
 * @plv8ify_grant admin
 */
export function secureFunction(id: string): string {
  return id
}

/**
 * @plv8ify_revokes anon, PUBLIC
 * @plv8ify_grants authenticated
 */
export function pluralSynonymFunction(): void {}
`
    )

    try {
      const tsMorph = new TsMorph()
      tsMorph.createSourceFile(fixturePath)
      const functions = tsMorph.getFunctions()

      const secureFn = functions.find((f) => f.name === 'secureFunction')
      expect(secureFn).toBeDefined()
      expect(secureFn!.revokes).toEqual(['PUBLIC', 'anon'])
      expect(secureFn!.grants).toEqual(['authenticated', 'service_role', 'admin'])

      const pluralFn = functions.find((f) => f.name === 'pluralSynonymFunction')
      expect(pluralFn).toBeDefined()
      expect(pluralFn!.revokes).toEqual(['anon', 'PUBLIC'])
      expect(pluralFn!.grants).toEqual(['authenticated'])
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })

  it('parses security annotations correctly', () => {
    const fixturePath = path.resolve('src/test-fixtures/security-test.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_security_definer
 */
export function definerTagOnly(): void {}

/**
 * @plv8ify_security_invoker
 */
export function invokerTagOnly(): void {}

/**
 * @plv8ify_security DEFINER
 */
export function definerTagUpper(): void {}

/**
 * @plv8ify_security definer
 */
export function definerTagLower(): void {}

/**
 * @plv8ify_security INVOKER
 */
export function invokerTagUpper(): void {}

/**
 * @plv8ify_security invoker
 */
export function invokerTagLower(): void {}

/**
 * @plv8ify_security SECURITY DEFINER
 */
export function definerFullClause(): void {}

/**
 * @plv8ify_security SECURITY INVOKER
 */
export function invokerFullClause(): void {}

export function defaultSecurity(): void {}
`
    )

    try {
      const tsMorph = new TsMorph()
      tsMorph.createSourceFile(fixturePath)
      const functions = tsMorph.getFunctions()

      expect(functions.find((f) => f.name === 'definerTagOnly')?.security).toBe('DEFINER')
      expect(functions.find((f) => f.name === 'invokerTagOnly')?.security).toBe('INVOKER')
      expect(functions.find((f) => f.name === 'definerTagUpper')?.security).toBe('DEFINER')
      expect(functions.find((f) => f.name === 'definerTagLower')?.security).toBe('DEFINER')
      expect(functions.find((f) => f.name === 'invokerTagUpper')?.security).toBe('INVOKER')
      expect(functions.find((f) => f.name === 'invokerTagLower')?.security).toBe('INVOKER')
      expect(functions.find((f) => f.name === 'definerFullClause')?.security).toBe('DEFINER')
      expect(functions.find((f) => f.name === 'invokerFullClause')?.security).toBe('INVOKER')
      expect(functions.find((f) => f.name === 'defaultSecurity')?.security).toBeUndefined()
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })

  it('parses search_path annotations correctly', () => {
    const fixturePath = path.resolve('src/test-fixtures/search-path-test.fixture.ts')
    fs.writeFileSync(
      fixturePath,
      `
/**
 * @plv8ify_search_path
 */
export function defaultEmptyPath(): void {}

/**
 * @plv8ify_search_path ''
 */
export function singleQuotedEmptyPath(): void {}

/**
 * @plv8ify_search_path ""
 */
export function doubleQuotedEmptyPath(): void {}

/**
 * @plv8ify_search_path = ''
 */
export function equalsEmptyPath(): void {}

/**
 * @plv8ify_search_path public
 */
export function singleSchemaPath(): void {}

/**
 * @plv8ify_search_path public, pg_temp
 */
export function multipleSchemasPath(): void {}

/**
 * @plv8ify_search_path 'public', 'pg_temp'
 */
export function quotedSchemasPath(): void {}

/**
 * @plv8ify_searchpath app, public
 */
export function aliasSearchpath(): void {}

export function noSearchPath(): void {}
`
    )

    try {
      const tsMorph = new TsMorph()
      tsMorph.createSourceFile(fixturePath)
      const functions = tsMorph.getFunctions()

      expect(functions.find((f) => f.name === 'defaultEmptyPath')?.searchPath).toBe("''")
      expect(functions.find((f) => f.name === 'singleQuotedEmptyPath')?.searchPath).toBe("''")
      expect(functions.find((f) => f.name === 'doubleQuotedEmptyPath')?.searchPath).toBe("''")
      expect(functions.find((f) => f.name === 'equalsEmptyPath')?.searchPath).toBe("''")
      expect(functions.find((f) => f.name === 'singleSchemaPath')?.searchPath).toBe('public')
      expect(functions.find((f) => f.name === 'multipleSchemasPath')?.searchPath).toBe('public, pg_temp')
      expect(functions.find((f) => f.name === 'quotedSchemasPath')?.searchPath).toBe("'public', 'pg_temp'")
      expect(functions.find((f) => f.name === 'aliasSearchpath')?.searchPath).toBe('app, public')
      expect(functions.find((f) => f.name === 'noSearchPath')?.searchPath).toBeUndefined()
    } finally {
      if (fs.existsSync(fixturePath)) {
        fs.unlinkSync(fixturePath)
      }
    }
  })

  it('resolves basic types, arrays, custom types, namespaces, and unions', () => {
    const tsMorph = new TsMorph()
    tsMorph.createSourceFile('./src/test-fixtures/types-resolution.fixture.ts')
    const functions = tsMorph.getFunctions()

    const basicFn = functions.find((f) => f.name === 'testBasic')!
    expect(basicFn).toBeDefined()
    expect(basicFn.returnType).toEqual('void')
    expect(basicFn.parameters).toEqual([
      { name: 'a', type: 'number' },
      { name: 'b', type: 'string' },
      { name: 'c', type: 'boolean' },
    ])

    const arraysFn = functions.find((f) => f.name === 'testArrays')!
    expect(arraysFn).toBeDefined()
    expect(arraysFn.returnType).toEqual('number[]')
    expect(arraysFn.parameters).toEqual([
      { name: 'a', type: 'number[]' },
      { name: 'b', type: 'string[]' },
      { name: 'c', type: 'boolean[]' },
    ])

    const customTypesFn = functions.find((f) => f.name === 'testCustomTypes')!
    expect(customTypesFn).toBeDefined()
    expect(customTypesFn.returnType).toEqual('Point')
    expect(customTypesFn.parameters).toEqual([
      { name: 'p', type: 'Point' },
      { name: 'points', type: 'Point[]' },
      { name: 'pointsGeneric', type: 'Point[]' },
    ])

    const namespacesFn = functions.find((f) => f.name === 'testNamespaces')!
    expect(namespacesFn).toBeDefined()
    expect(namespacesFn.returnType).toEqual('Coord')
    expect(namespacesFn.parameters).toEqual([
      { name: 'c', type: 'Coord' },
      { name: 'coords', type: 'Coord[]' },
      { name: 'coordsGeneric', type: 'Coord[]' },
    ])

    const unionsFn = functions.find((f) => f.name === 'testUnions')!
    expect(unionsFn).toBeDefined()
    expect(unionsFn.returnType).toEqual('string | number')
    expect(unionsFn.parameters).toEqual([
      { name: 'u', type: 'string | number' },
    ])
  })
})
