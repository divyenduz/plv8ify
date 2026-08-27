import { describe, expect, it } from 'bun:test'
import { parseCustomTypeMap } from './CustomTypeMap.js'

describe('CustomTypeMap helper tests', () => {
  it('returns empty object when typesFilePath is undefined or does not exist', () => {
    expect(parseCustomTypeMap(undefined)).toEqual({})
    expect(parseCustomTypeMap('')).toEqual({})
    expect(parseCustomTypeMap('./src/test-fixtures/non-existent.ts')).toEqual({})
  })

  it('parses custom type mapping from legacy assignment fixture', () => {
    const result = parseCustomTypeMap('./src/test-fixtures/types-custom.fixture.js')
    expect(result).toEqual({
      test_type: 'test_type',
      'test_type[]': 'test_type[]',
    })
  })

  it('parses custom type mapping from TypeScript named export fixture', () => {
    const result = parseCustomTypeMap('./src/test-fixtures/types-named-export.fixture.ts')
    expect(result).toEqual({
      CustomGeo: 'geometry(Point, 4326)',
      'CustomGeo[]': 'geometry(Point, 4326)[]',
    })
  })

  it('parses custom type mapping from TypeScript default export fixture', () => {
    const result = parseCustomTypeMap('./src/test-fixtures/types-default-export.fixture.ts')
    expect(result).toEqual({
      UserId: 'uuid',
      'UserId[]': 'uuid[]',
    })
  })

  it('parses custom type mapping from JSON config fixture', () => {
    const result = parseCustomTypeMap('./src/test-fixtures/types-json.fixture.json')
    expect(result).toEqual({
      JsonType: 'jsonb',
      'JsonType[]': 'jsonb[]',
    })
  })

  it('safely parses AST without executing executable side effects in the file', () => {
    delete (globalThis as any).__MALICIOUS_SIDE_EFFECT_EXECUTED__
    const result = parseCustomTypeMap('./src/test-fixtures/types-security.fixture.ts')
    expect((globalThis as any).__MALICIOUS_SIDE_EFFECT_EXECUTED__).toBeUndefined()
    expect(result).toEqual({
      SecuredType: 'varchar(64)',
    })
  })
})
